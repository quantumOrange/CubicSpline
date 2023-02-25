//
//  PointsShape.swift
//  Spline
//
//  Created by David Crooks on 17/07/2021.
//

import SwiftUI
import CubicSpline

@available(iOS 13.0, macOS 10.15, *)
struct SplinePointsShape:Shape {
    let spline:CubicSpline
   
    let radius:CGFloat
    
    func path(in rect: CGRect) -> Path {

        let bounds = spline.path.boundingRect
        let transform = bounds.transformToFill(rect:rect)
        let points = spline
                        .endPoints
                        .map { $0.cgPoint.applying(transform) }
                       
        return points.pathOfDots(radius: radius)
    }
}

fileprivate let spline = CubicSpline(points: [[0.0,1.0],
                                            [0.2,0.3],
                                          [1.0,0.0],
                                            [1.4,0.6],
                                            [2,1.0]])


@available(iOS 13.0, macOS 10.15, *)
struct PointsShape_Previews: PreviewProvider {
    static var previews: some View {
        SplinePointsShape(spline: spline, radius: 5)
            .padding()
            .padding()
    }
}


