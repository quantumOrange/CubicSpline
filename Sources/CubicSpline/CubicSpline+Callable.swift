//
//  CubicSpline+Callable.swift
//  
//
//  Created by David Crooks on 25/02/2023.
//

import Foundation
import simd

extension CubicCurve {
    public func callAsFunction(t:Double) -> S { f(t) }
}

extension CubicSpline {
    public func callAsFunction(t:Double) -> S {
        guard let last = cubicCurves.last, let first = cubicCurves.first else {return S.zero}
        guard t < 1 else {return last.end}
        guard t >= 0 else {return first.start}
        
        let T = t * Double(cubicCurves.count)
        let i = Int(T)
        let v = T - Double(i)
        
        let curve = cubicCurves[i]
        
        return curve(t: v)
    }
}

extension CubicCurve  where  S==SIMD3<Double> {
    public func tubePoint(s:Double,t:Double, radius r:Double ) -> (position:SIMD3<Double>,normal:SIMD3<Double>) {
        let n1 = normalize(ddf(t))
        let n2 = cross(n1, df(t))
        
        let p = f(t)
        
        let n =  cos(2 * .pi * s) * n1  + sin(2 * .pi * s) * n2
        let q =  p + r * n
        
        return (q,n)
    }
}

extension CubicSpline where S==SIMD3<Double> {
    public func tubePoint(s:Double,t:Double,r:Double)  -> (position:SIMD3<Double>,normal:SIMD3<Double>)
    {
        guard let last = cubicCurves.last, let first = cubicCurves.first else {return (SIMD3<Double>.zero,SIMD3<Double>.zero)}
        guard t < 1 else { return last.tubePoint(s:s,t:1.0,radius:r)}
        guard t >= 0 else { return first.tubePoint(s:s,t:0.0,radius:r)}
        
        let T = t * Double(cubicCurves.count)
        let i = Int(T)
        let v = T - Double(i)
        
        let curve = cubicCurves[i]
        
        return curve.tubePoint(s:s,t:v,radius:r)
    }
    
    public func point(t:Double)  -> SIMD3<Double>
    {
        guard let last = cubicCurves.last, let first = cubicCurves.first else {return SIMD3<Double>.zero}
        guard t < 1 else { return last.f(1)}
        guard t >= 0 else { return first.f(0)}
        
        let T = t * Double(cubicCurves.count)
        let i = Int(T)
        let v = T - Double(i)
        
        let curve = cubicCurves[i]
        
        return curve.f(v)
    }
}


