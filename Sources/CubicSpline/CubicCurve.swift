//
//  CubicCurve.swift
//  
//
//  Created by David Crooks on 21/02/2023.
//

import Foundation

public typealias CubicCurve2D = CubicCurve<SIMD2<Double>>
public typealias CubicCurve3D = CubicCurve<SIMD3<Double>>
public typealias CubicCurve4D = CubicCurve<SIMD4<Double>>

public struct CubicCurve<S:SIMD> where S.Scalar == Double  {
    
    let a: S
    let b: S
    let c: S
    let d: S
    
    public var start: S {
        a
    }
    
    public var end: S {
        a + b + c + d
    }
    
    public var bezierControlPoint1:S {
        a + b / 3.0
    }

    public var bezierControlPoint2:S {
        a + 2 * b / 3.0 + c / 3.0
    }

    public func f(_ t:Double) -> S {
        let t_2:Double = t * t
        let t_3:Double = t_2  * t
        
        let r1:S = a + (b * t)
        let r2:S = (c * t_2)  + (d * t_3)
        
        return r1 + r2
    }
    
    public func df(_ t:Double) -> S {
        
        let t_2:Double = t * t
        let r1:S = b
        let r2:S = (2 * c * t)  + (3 * d * t_2)
        
        return r1 + r2
    }
    
    public func ddf(_ t:Double) -> S {
        2 * c + 6 * d * t
    }
    
    init(start: S, end: S, derivativeStart c_start: S, derivativeEnd c_end: S ) {
        self.a = start
        self.b = c_start
        self.c = 3 * (end - start) - 2 * c_start - c_end
        self.d = 2 * (start - end) + c_start + c_end
    }
    
    init(a: S, b: S, c: S, d: S) {
        self.a = a
        self.b = b
        self.c = c
        self.d = d
    }
    
    
}


extension CubicCurve<SIMD3<Double>> {
    public init(curve c:CubicCurve<SIMD2<Double>>, y:Double) {
        self.a = [c.a.x,y,c.a.y]
        self.b = [c.b.x,y,c.b.y]
        self.c = [c.c.x,y,c.c.y]
        self.d = [c.d.x,y,c.d.y]
    }
}

extension CubicCurve : Codable {
    
}
