//
//  File.swift
//  
//
//  Created by David Crooks on 21/02/2023.
//

import Foundation
import SwiftUI
import CubicSpline

@available(iOS 13.0, macOS 10.15, *)
struct SplineShape : Shape {
    let spline:CubicSpline
    
    func path(in rect: CGRect) -> Path {
        let path = spline.path
        let bounds = path.boundingRect
        
        let transform = bounds.transformToFill(rect:rect)
        
        return path.applying(transform)
    }
}

extension CGRect {
    func transformToFill(rect:CGRect) -> CGAffineTransform {
        let scaleX = rect.width / width
        let scaleY = rect.height / height
        
        let scale = CGAffineTransform(scaleX: scaleX, y: scaleY)
        
        let dx =  rect.origin.x - origin.x
        let dy =  rect.origin.y - origin.y
        
        let translation = CGAffineTransform(translationX: dx, y: dy)
        
        return translation.concatenating(scale)
    }
}
