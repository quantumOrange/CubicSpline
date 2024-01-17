//
//  CubicSpline.swift
//
//
//  Created by David Crooks on 21/02/2023.
//

import Foundation
import simd

#if os(Linux)
    import CLapacke_Linux
    typealias LAInt = Int32
#else
    import Accelerate
    typealias LAInt = __CLPK_integer
#endif

public struct CubicSpline {
    public var closed:Bool
    public var cubicCurves:[CubicCurve]
    
    public init() {
        self.cubicCurves = []
        self.closed = false
    }
    
    mutating func append(points:[SIMD2<Double>]) {
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
    
    public init(points:[SIMD2<Double>], closed: Bool = false) {
        // The maths for the following calculation can be found here:
        // https://mathworld.wolfram.com/CubicSpline.html
        self.closed = closed
        let n = points.count
        
        var vec:[SIMD2<Double>] = []
        
        guard (n >= 2) else {
            self.cubicCurves = []
            return
        }
        
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
        print("OK1")
        var derivatives:[SIMD2<Double>] = []
        do {
            derivatives = try Self.solve(vec, closed: closed)
        }
        catch {
            print(error)
            self.cubicCurves = []
            return
        }
        
        let pointPairs =  closed ? points.cyclicAdjacentPairs() : points.adjacentPairs()
        let derivativePairs = closed ? derivatives.cyclicAdjacentPairs() : points.adjacentPairs()
      
        let zippedPairs = zip(pointPairs,derivativePairs)
        
        self.cubicCurves = zippedPairs.map { pointPairs, controlPairs in
            let (start, end) =  pointPairs
            let (c_start, c_end) = controlPairs
            return CubicCurve(start: start, end: end, derivativeStart: c_start, derivativeEnd: c_end)
        }
    }
    
    static func solve(_ v:[SIMD2<Double>], closed:Bool) throws -> [SIMD2<Double>] {
        if closed {
            return try solveClosed(v)
        }
        else {
            return try solveOpen(v)
        }
    }
    
    static func solveOpen(_ v:[SIMD2<Double>]) throws -> [SIMD2<Double>] {
        // We need to solve the matrix equation M * d = v
        // where M is a tri-diagonal matrix:
        
        //  2   1   0   0   0 ...    0
        //  1   4   1   0   0 ...    0
        //  0   1   4   1   0 ...    0
        //  0   0   1   4   1 ...    0
        // ...
        //  0   0   0   0 ...   1   4   1
        //  0   0   0   0 ...   0   1   2
        
        // The lapack function dptsv will solve this efficiently:
        // http://www.netlib.org/lapack/explore-html/d9/dc4/group__double_p_tsolve_gaf1bd4c731915bd8755a4da8086fd79a8.html#gaf1bd4c731915bd8755a4da8086fd79a8
        
        var b = v.toDoubleArray()
        
        var diaganol = Array<Double>(repeating: 4, count: v.count)
        diaganol[0] = 2
        diaganol[v.count-1] = 2
        var subDiagonal = Array<Double>(repeating: 1, count: v.count - 1)
        var n:LAInt = Int32(v.count)
        var nrhs:LAInt = 2
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
                return b.toSIMD2Array()
            case let i where i > 0:
                throw LaPackError.leadingMinorNotPositiveDefinit(Int(i))
               // assertionFailure("Error: The leading minor of order \(i) is not positive definite, and the solution has not been computed.  The factorization has not been completed unless \(i) = N.")
            case let i where i < 0:
                throw LaPackError.illegalValue(Int(i))
            default:
                throw LaPackError.impossibleError
        }
        
    }
    
    static func solveClosed(_ v:[SIMD2<Double>]) throws -> [SIMD2<Double>] {
        // We need to solve the matrix equation M * d = v
        // where M is the matrix:
        
        //  4   1   0   0   0 ...    1
        //  1   4   1   0   0 ...    0
        //  0   1   4   1   0 ...    0
        //  0   0   1   4   1 ...    0
        // ...
        //  0   0   0   0    1   4   1
        //  1   0   0   0    0   1   4
        let n = v.count
        var nn = Int32(n)
       // var ret = [Double](repeating: Double(), count: 2*v.count)
        var ipiv = Array<Int32>(repeating: 0, count: n)
        //var ipiv:Int32 = 0
        var a = Array<Double>(repeating: 0, count:n*n)
       
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
        
        print("-------")
        for i in 0..<n {
            var str = ""
            for j in 0..<n {
                str.append("\(Int(M[i,j])),")
            }
            print(str)
        }
        print("-------")
        var b = v.toDoubleArray()
        
       // _ = cblas_dcopy(Int32(v.count), &b, 1, &ret, 1)
        var nrhs:LAInt = 2
        var info:LAInt = 0
        
        _ = withUnsafeMutablePointer(to: &nn) { N in
            withUnsafeMutablePointer(to: &nrhs) { NRHS in
                 //withUnsafeMutablePointer(to: &ipiv, { IPIV in
                     withUnsafeMutablePointer(to: &info) { INFO in
                         dgesv_(N, NRHS, &M.grid, N, &ipiv, &b, N, INFO)
                     }
                // })'dgesv_' was deprecated in visionOS 1.0: The CLAPACK interface is deprecated.  Please compile with -DACCELERATE_NEW_LAPACK to access the new lapack headers.
             }
         }

        // error handling
        /*
        INFO is INTEGER
                  = 0:  successful exit
                  < 0:  if INFO = -i, the i-th argument had an illegal value
                  > 0:  if INFO = i, U(i,i) is exactly zero.  The factorization
                        has been completed, but the factor U is exactly
                        singular, so the solution could not be computed.
         */
        switch info {
            case 0:
                return b.toSIMD2Array()
            case let i where i > 0:
                throw LaPackError.leadingMinorNotPositiveDefinit(Int(i))
               // assertionFailure("Error: The leading minor of order \(i) is not positive definite, and the solution has not been computed.  The factorization has not been completed unless \(i) = N.")
            case let i where i < 0:
                throw LaPackError.illegalValue(Int(i))
            default:
                throw LaPackError.impossibleError
        }
    }
}

extension CubicSpline {
    public var endPoints:[SIMD2<Double>] {
        cubicCurves.endPoints
    }
}

enum LaPackError:Error {
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
        case .impossibleError:
            return NSLocalizedString("This error is impossible. If you are seeing this you do not exist.", comment: "Impossible error.")
        }
    }
}


struct Matrix {
    let rows: Int, columns: Int
    var grid: [Double]
    init(rows: Int, columns: Int) {
        self.rows = rows
        self.columns = columns
        grid = Array(repeating: 0.0, count: rows * columns)
    }
    func indexIsValid(row: Int, column: Int) -> Bool {
        return row >= 0 && row < rows && column >= 0 && column < columns
    }
    subscript(row: Int, column: Int) -> Double {
        get {
            assert(indexIsValid(row: row, column: column), "Index out of range")
            return grid[(row * columns) + column]
        }
        set {
            assert(indexIsValid(row: row, column: column), "Index out of range")
            grid[(row * columns) + column] = newValue
        }
    }
}

extension Array {
    func cyclicAdjacentPairs() ->  Zip2Sequence<[Element], ArraySlice<Element>> {
        guard let first else { return adjacentPairs() }
        var arr = self
        arr.append(first)
        return arr.adjacentPairs()
    }
}
