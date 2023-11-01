//
//  File.swift
//  
//
//  Created by David Crooks on 11/06/2023.
//

import Foundation
import simd

public struct CubicCurve3D {
    
    let a: SIMD3<Double>
    let b: SIMD3<Double>
    let c: SIMD3<Double>
    let d: SIMD3<Double>
    
    public var start: SIMD3<Double> {
        a
    }
    
    public var end: SIMD3<Double> {
        a + b + c + d
    }
    
    public var bezierControlPoint1:SIMD3<Double> {
        a + b / 3.0
    }

    public var bezierControlPoint2:SIMD3<Double> {
        a + 2 * b / 3.0 + c / 3.0
    }

    public func f(_ t:Double) -> SIMD3<Double> {
        let t_2:Double = t * t
        let t_3:Double = t_2  * t
        
        let r1:SIMD3<Double> = a + (b * t)
        let r2:SIMD3<Double> = (c * t_2)  + (d * t_3)
        
        return r1 + r2
    }
    
    public func df(_ t:Double) -> SIMD3<Double> {
        
        let t_2:Double = t * t
        let r1:SIMD3<Double> = b
        let r2:SIMD3<Double> = (2 * c * t)  + (3 * d * t_2)
        
        return r1 + r2
    }
    
    func ddf(_ t:Double) -> SIMD3<Double> {
        2 * c + 6 * d * t
    }
    
    public func tubePoint(s:Double,t:Double, radius r:Double ) -> (position:SIMD3<Double>,normal:SIMD3<Double>) {
        let n1 = normalize(ddf(t))
        let n2 = cross(n1, df(t))
        
        let p = f(t)
        
        let n =  cos(2 * .pi * s) * n1  + sin(2 * .pi * s) * n2
        let q =  p + r * n
        
        return (q,n)
    }
    
    init(start: SIMD3<Double>, end: SIMD3<Double>, derivativeStart c_start: SIMD3<Double>, derivativeEnd c_end: SIMD3<Double> ) {
        self.a = start
        self.b = c_start
        self.c = 3 * (end - start) - 2 * c_start - c_end
        self.d = 2 * (start - end) + c_start + c_end
    }
}


