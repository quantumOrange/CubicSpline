import Foundation
import Accelerate
import simd


typealias LAInt = __CLPK_integer

public struct CubicSpline {
    
    
    
    public var segments:[CubicCurve]
    
    public init() {
        self.segments = []
    }
    
    mutating func append(points:[SIMD2<Double>]) {
        guard segments.count > 1 else {
            let allPoints = segments.endPoints + points
            let newSpline = CubicSpline(points:allPoints )
            segments = newSpline.segments
            return
        }
        
        let two = segments.removeLast()
        let one = segments.last!
        
        let lastThreePoints = [one,two].endPoints
        
        let allPoints = lastThreePoints + points
        
        let newSpline = CubicSpline(points:allPoints )
        
        segments.append(contentsOf:newSpline.segments.dropFirst())
    }
    
    public init(points:[SIMD2<Double>]) {
        let n = points.count
        //https://mathworld.wolfram.com/CubicSpline.html
        var vec:[SIMD2<Double>] = []
        
        guard (n >= 2) else {
            self.segments = []
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
        
        guard let control = Self.solve(vec: vec) else {
            self.segments = []
            return }
        
        let pointPairs = zip(points, points.dropFirst())
       let controlPairs = zip(control, control.dropFirst())
      ///  let pointPairs = points.a
       //  let controlPairs = zip(control, control.dropFirst())
        let zippedPairs = zip(pointPairs,controlPairs)
        
        self.segments = zippedPairs.map { pointPairs, controlPairs in
            let (start, end) =  pointPairs
            let (c_start, c_end) = controlPairs
            return CubicCurve(start: start, end: end, controlStart: c_start, controlEnd: c_end)
        }
    }
    
    static func solve(vec:[SIMD2<Double>]) ->[SIMD2<Double>]? {
        //http://www.netlib.org/lapack/explore-html/d9/dc4/group__double_p_tsolve_gaf1bd4c731915bd8755a4da8086fd79a8.html#gaf1bd4c731915bd8755a4da8086fd79a8
        var b = vec.toDoubleArray()
        
        var diaganol = Array<Double>(repeating: 4, count: vec.count)
        diaganol[0] = 2
        diaganol[vec.count-1] = 2
        var subDiagonal = Array<Double>(repeating: 1, count: vec.count - 1)
        var n:LAInt = Int32(vec.count)
        var nrhs:LAInt = 2
        var info:LAInt = 0
        
        _ = withUnsafeMutablePointer(to: &n) { N in
            withUnsafeMutablePointer(to: &nrhs) { NRHS in
                withUnsafeMutablePointer(to: &info) { INFO in
                    dptsv_(N, NRHS, &diaganol, &subDiagonal, &b, N, INFO)
                }
            }
        }
        
        if info == 0 {
            return b.toSIMD2Array()
        }
        else {
            print("Error \(info)")
        }
        
        return nil
    }
}

