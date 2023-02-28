//
//  File.swift
//  
//
//  Created by David Crooks on 25/02/2023.
//

import Foundation

extension CubicCurve {
    public func callAsFunction(t:Double) -> SIMD2<Double> { f(t) }
}

extension CubicSpline {
    public func callAsFunction(t:Double) -> SIMD2<Double> {
        guard let last = cubicCurves.last, let first = cubicCurves.first else {return SIMD2<Double>.zero}
        guard t < 1 else {return last.end}
        guard t >= 0 else {return first.start}
        
        let T = t * Double(cubicCurves.count)
        let i = Int(T)
        let v = T.remainder(dividingBy: 1)
        
        let curve = cubicCurves[i]
        
        return curve(t: v)
    }
}
