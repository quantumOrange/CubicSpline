//
//  SplineShape.swift
//  
//
//  Created by David Crooks on 21/02/2023.
//

import Foundation
import SwiftUI
import CubicSpline

@available(iOS 13.0, macOS 10.15, *)
struct SplineShape : Shape {
    let spline:CubicSpline<SIMD2<Double>>
    
    func path(in rect: CGRect) -> Path {
        let path = spline.path
        let bounds = path.boundingRect
        
        let transform = bounds.transformToFill(rect:rect)
        
        return path.applying(transform)
    }
}

