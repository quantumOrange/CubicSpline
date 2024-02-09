//
//  CubicSpline.swift
//
//
//  Created by David Crooks on 21/02/2023.
//

import Foundation
import simd

public typealias CubicCurve2D = CubicCurve<SIMD2<Double>>
public typealias CubicCurve3D = CubicCurve<SIMD3<Double>>
public typealias CubicCurve4D = CubicCurve<SIMD4<Double>>

#if os(Linux)
    import CLapacke_Linux
    typealias LAInt = Int32
#else
    import Accelerate
    typealias LAInt = __CLPK_integer
#endif

public struct CubicSpline<S:Flattenable> where S.Scalar == Double {
    public var closed:Bool
    public var cubicCurves:[CubicCurve<S>]
    
    public init() {
        self.cubicCurves = []
        self.closed = false
    }
    
    mutating func append(points:[S]) {
        guard cubicCurves.count > 1 else {
            let allPoints = cubicCurves.endPoints + points
            let newSpline = CubicSpline(points:allPoints )
            cubicCurves = newSpline.cubicCurves
            return
        }
        
        let two = cubicCurves.removeLast()
        let one = cubicCurves.last!
        
        let lastThreePoints = [one,two].endPoints
        
        let allPoints = lastThreePoints + points
        
        let newSpline = CubicSpline(points:allPoints )
        
        cubicCurves.append(contentsOf:newSpline.cubicCurves.dropFirst())
    }
    
    public init(points:[S], closed: Bool = false) {
        // The maths for the following calculation can be found here:
        // https://mathworld.wolfram.com/CubicSpline.html
        self.closed = closed
       
        let n = points.count

        var vec:[S] = []
        
        guard (n >= 2) else {
            self.cubicCurves = []
            return
        }
        
        if closed {
            for i in 0..<n  {
                if i == 0 {
                    vec.append( 3 * ( points[1] - points[n-1] ))
                }
                else if i == n - 1 {
                    vec.append( 3 * ( points[0] - points[n-2] ))
                }
                else {
                    vec.append( 3 * ( points[i + 1] - points[i-1] ))
                }
            }
        }
        else {
            for i in 0..<n  {
                if i == 0 {
                    vec.append( 3 * ( points[1] - points[0] ))
                }
                else if i == n - 1 {
                    vec.append( 3 * ( points[n-1] - points[n-2] ))
                }
                else {
                    vec.append( 3 * ( points[i + 1] - points[i-1] ))
                }
            }
        }
        
        
        var derivatives:[S] = []
        
        do {
            derivatives = try Self.solve(vec, closed: closed)
        }
        catch {
            print(error)
            self.cubicCurves = []
            return
        }
        
        let pointPairs =  closed ? points.cyclicAdjacentPairs() : points.adjacentPairs()
        let derivativePairs = closed ? derivatives.cyclicAdjacentPairs() : derivatives.adjacentPairs()
      
        let zippedPairs = zip(pointPairs,derivativePairs)
        
        self.cubicCurves = zippedPairs.map { pointPairs, controlPairs in
            let (start, end) =  pointPairs
            let (c_start, c_end) = controlPairs
            return CubicCurve(start: start, end: end, derivativeStart: c_start, derivativeEnd: c_end)
        }
    }
    
    static func solve(_ v:[S], closed:Bool) throws -> [S] {
        if closed {
            return try solveClosed(v)
        }
        else {
            return try solveOpen(v)
        }
    }
    
    static func solveOpen(_ v:[S]) throws -> [S] {
        // We need to solve the matrix equation M * d = v
        // where M is a tri-diagonal matrix:
        
        //  2   1   0   0   0    ...    0
        //  1   4   1   0   0    ...    0
        //  0   1   4   1   0    ...    0
        //  0   0   1   4   1    ...    0
        // ...
        //  0   0   0   0  ...  1   4   1
        //  0   0   0   0  ...  0   1   2
        
        // The lapack function dptsv will solve this efficiently:
        // http://www.netlib.org/lapack/explore-html/d9/dc4/group__double_p_tsolve_gaf1bd4c731915bd8755a4da8086fd79a8.html#gaf1bd4c731915bd8755a4da8086fd79a8
        
        var b = S.toDoubleArray(array: v)
        //var b = v.toDoubleArray()
        
        var diaganol = Array<Double>(repeating: 4, count: v.count)
        diaganol[0] = 2
        diaganol[v.count-1] = 2
        var subDiagonal = Array<Double>(repeating: 1, count: v.count - 1)
        var n:LAInt = Int32(v.count)
        var nrhs:LAInt = LAInt(S.scalarCount)
        var info:LAInt = 0
        
        _ = withUnsafeMutablePointer(to: &n) { N in
            withUnsafeMutablePointer(to: &nrhs) { NRHS in
                withUnsafeMutablePointer(to: &info) { INFO in
                    dptsv_(N, NRHS, &diaganol, &subDiagonal, &b, N, INFO)
                }
            }
        }
        
        switch info {
            case 0:
                return S.toSIMDArray(array: b)
                //return b.toSIMD2Array()
            case let i where i > 0:
                throw LaPackError.leadingMinorNotPositiveDefinit(Int(i))
               // assertionFailure("Error: The leading minor of order \(i) is not positive definite, and the solution has not been computed.  The factorization has not been completed unless \(i) = N.")
            case let i where i < 0:
                throw LaPackError.illegalValue(Int(i))
            default:
                throw LaPackError.impossibleError
        }
        
    }
    
    static func solveClosed(_ v:[S]) throws -> [S] {
        // We need to solve the matrix equation M * d = v
        // where M is the matrix:
        
        //  4   1   0   0   0    ...    1
        //  1   4   1   0   0    ...    0
        //  0   1   4   1   0    ...    0
        //  0   0   1   4   1    ...    0
        // ...
        //  0   0   0   0  ...  1   4   1
        //  1   0   0   0  ...  0   1   4
        let n = v.count
        var nn = Int32(n)
       
        var ipiv = Array<Int32>(repeating: 0, count: n)
       
        var M = Matrix(rows: n,columns: n)
        
        for i in 0..<n {
            M[i,i] = 4
        }
        
        for i in 1..<n {
            M[i,i-1] = 1
            M[i-1,i] = 1
        }
        
        M[0,n-1] = 1
        M[n-1,0] = 1
        
        var b = S.toDoubleArray(array: v)
        
        var nrhs:LAInt = LAInt(S.scalarCount)
        var info:LAInt = 0
        
        _ = withUnsafeMutablePointer(to: &nn) { N in
            withUnsafeMutablePointer(to: &nrhs) { NRHS in
                     withUnsafeMutablePointer(to: &info) { INFO in
                         dgesv_(N, NRHS, &M.grid, N, &ipiv, &b, N, INFO)
                     }
             }
         }

        switch info {
            case 0:
                return S.toSIMDArray(array: b)
            case let i where i > 0:
                throw LaPackError.exactlyZero(Int(i))
            case let i where i < 0:
                throw LaPackError.illegalValue(Int(i))
            default:
                throw LaPackError.impossibleError
        }
    }
}

extension CubicSpline {
    public var endPoints:[S] {
        cubicCurves.endPoints
    }
}

enum LaPackError:Error {
    case exactlyZero(Int)
    case leadingMinorNotPositiveDefinit(Int)
    case illegalValue(Int)
    case impossibleError
}

extension LaPackError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .leadingMinorNotPositiveDefinit(let i):
            return NSLocalizedString("Error: The leading minor of order \(i) is not positive definite, and the solution has not been computed.  The factorization has not been completed unless \(i) = N.", comment: "LaPack Error")
        case .illegalValue(let i):
            return NSLocalizedString("Error: the \(i)-th argument had an illegal value.", comment: "LaPack Error")
            
        case .exactlyZero(let i):
            return NSLocalizedString("U(\(i),\(i)) is exactly zero.  The factorization has been completed, but the factor U is exactly singular, so the solution could not be computed.",comment: "LaPack Error")
        case .impossibleError:
            return NSLocalizedString("This error is impossible. If you are seeing this you do not exist.", comment: "Impossible error.")
        }
    }
}



