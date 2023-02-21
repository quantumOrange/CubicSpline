import Foundation
import Accelerate
import simd

typealias LAInt = __CLPK_integer

public struct CubicSpline {
    
    public struct Segment {
        
        let a: SIMD2<Double>
        let b: SIMD2<Double>
        let c: SIMD2<Double>
        let d: SIMD2<Double>
        
        public var start: SIMD2<Double> {
            a
        }
        
        public var end: SIMD2<Double> {
            a + b + c + d
        }
        
        public var bezierControlPoint1:SIMD2<Double> {
            a + b / 3.0
        }

        public var bezierControlPoint2:SIMD2<Double> {
            a + 2 * b / 3.0 + c / 3.0
        }

        public func f(_ t:Double) -> SIMD2<Double> {
            let t_2:Double = t * t
            let t_3:Double = t_2  * t
            
            let r1:SIMD2<Double> = a + (b * t)
            let r2:SIMD2<Double> = (c * t_2)  + (d * t_3)
            
            return r1 + r2
        }
        
        public func df(_ t:Double) -> SIMD2<Double> {
            
            let t_2:Double = t * t
            let r1:SIMD2<Double> = b
            let r2:SIMD2<Double> = (2 * c * t)  + (3 * d * t_2)
            
            return r1 + r2
        }
        
        func ddf(_ t:Double) -> SIMD2<Double> {
            2 * c + 6 * d * t
        }
        
        init(start: SIMD2<Double>, end: SIMD2<Double>, controlStart c_start: SIMD2<Double>, controlEnd c_end: SIMD2<Double> ) {
            self.a = start
            self.b = c_start
            self.c = 3 * (end - start) - 2 * c_start - c_end
            self.d = 2 * (start - end) + c_start + c_end
        }
    }
    
    public var segments:[Segment]
    
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
        let zipedPairs = zip(pointPairs,controlPairs)
        
        self.segments = zipedPairs.map { pointPairs, controlPairs in
            let (start, end) =  pointPairs
            let (c_start, c_end) = controlPairs
            return Segment(start: start, end: end, controlStart: c_start, controlEnd: c_end)
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

