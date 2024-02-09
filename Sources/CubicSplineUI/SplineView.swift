//
//  SplineView.swift
//  
//
//  Created by David Crooks on 21/02/2023.
//

import SwiftUI
import CubicSpline

@available(iOS 13.0, macOS 12.0, *)
public struct SplineView: View {
    let spline:CubicSpline<SIMD2<Double>>
    
    public init(spline: CubicSpline<SIMD2<Double>>) {
        self.spline = spline
    }
    
    public var body: some View {
        SplineShape(spline:spline)
            .stroke()
            .overlay(SplinePointsShape(spline: spline, radius: 3)
                .fill())
            
    }
}

fileprivate let points:[SIMD2<Double>] = [[0.0,0.9],
                                          [0.3,1.0],
                                          [0.7,0.0],
                                          [0.9,0.6],
                                            [1.4,0.6],
                                            [2,1.0]

]

fileprivate let loop:[SIMD2<Double>] = [[0.9,0.5],
                                            [0.7,0],
                                          [0.3,0.3],
                                          [1.0,1.0],
                                          [1.4,0.3],
                                            [2,0.45],
                                            [1.1,0.6],
                                          
]


fileprivate let trefoil:[SIMD2<Double>] = [ [-0.19,-0.39],
                                             [-0.38,-0.35],
                                             [-0.39,-0.13],
                                             [-0.21,0.06],
                                             [-0.00,0.11],
                                             [0.21,0.06],
                                             [0.41,-0.13],
                                             [0.37,-0.36],
                                             [0.19,-0.41],
                                             [0.02,-0.29],
                                             [-0.12,-0.14],
                                             [-0.21,0.06],
                                             [-0.19,0.29],
                                             [0.01,0.42],
                                             [0.19,0.28],
                                             [0.21,0.06],
                                             [0.14,-0.13],
                                             [0.02,-0.29],
                                          
]

@available(iOS 13.0, macOS 12.0, *)
struct SplineView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            
            SplineView(spline:CubicSpline(points:points) )
                .padding()
            
            SplineView(spline:CubicSpline(points:trefoil, closed: true) )
                .padding()
            
            SplineView(spline:CubicSpline(points:loop, closed: true) )
                .padding()
               
        }
        .padding()
        
       
    }
}
