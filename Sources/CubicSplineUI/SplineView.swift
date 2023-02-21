//
//  SwiftUIView.swift
//  
//
//  Created by David Crooks on 21/02/2023.
//

import SwiftUI
import CubicSpline

@available(iOS 13.0, macOS 10.15, *)
public struct SplineView: View {
    let spline:CubicSpline
    
    public var body: some View {
        SplineShape(spline:spline)
            .stroke()
    }
}

@available(iOS 13.0, macOS 10.15, *)
struct SplineView_Previews: PreviewProvider {
    static var previews: some View {
        SplineView(spline:CubicSpline(points: [[1.2,0.2],
             [1.3,0.3],
             [1.4,0.95],
             [1.7,0.6],
             [1.9,0.9]]) )
        .padding()
    }
}
