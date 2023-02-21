//
//  File.swift
//  
//
//  Created by David Crooks on 17/07/2021.
//

import Foundation

extension Array where Element==CubicSpline.Segment {
    var endPoints:[SIMD2<Double>] {
        guard let last = last else {return []}
        var points = map { $0.start }
        points.append(last.end)
        return points
    }
}
