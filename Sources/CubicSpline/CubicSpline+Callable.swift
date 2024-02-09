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
