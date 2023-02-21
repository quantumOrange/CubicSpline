//
//  PointGenerartor.swift
//  Spline
//
//  Created by David Crooks on 12/07/2021.
//

import Foundation

public func getSinusoidalPoints(n:Int) -> [SIMD2<Double>]{
    (0..<n).map {
        Double($0)/Double(n-1)
    }.map {
        let theta = 2.0 * $0 * .pi
        let y = 0.5 + 0.5 * sin(theta)
        return SIMD2<Double>($0, y )
    }
}
