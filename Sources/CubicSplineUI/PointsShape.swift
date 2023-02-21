//
//  PointsShape.swift
//  Spline
//
//  Created by David Crooks on 17/07/2021.
//

import SwiftUI

@available(iOS 13.0, macOS 10.15, *)
struct PointsShape:Shape {
    let points:[CGPoint]
    let radius:CGFloat
    
    func path(in rect: CGRect) -> Path {
        
        var path = Path()
        
        for p in points {
            let rect = CGRect(x: p.x - radius , y: p.y - radius, width: 2*radius, height: 2*radius)
            let newPath = Path(ellipseIn: rect)
            path.addPath(newPath)
        }
        
        return path
    }
}

@available(iOS 13.0, macOS 10.15, *)
struct PointsShape_Previews: PreviewProvider {
    static var previews: some View {
        PointsShape(points:[
                        CGPoint(x:1.2,y:0.2),
                        CGPoint(x:1.3,y:0.3),
                        CGPoint(x:1.4,y:0.95),
                        CGPoint(x:1.7,y:0.6),
                        CGPoint(x:1.9,y:0.9)
                    ],
                    radius: 5)
    }
}

