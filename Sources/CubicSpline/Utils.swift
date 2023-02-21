//
//  PointGenerartor.swift
//  Spline
//
//  Created by David Crooks on 12/07/2021.
//

import Foundation


//import UIKit

func scaleToRect(_ rect:CGRect) -> (SIMD2<Double>) -> (SIMD2<Double>) {
    { p in
        SIMD2<Double>(x: CGFloat(p.x) * rect.size.width, y: CGFloat(p.y) * rect.size.height)
    }
}


func toCGPoint(_ rect:CGRect) -> (SIMD2<Double>) -> CGPoint {
    { p in
        CGPoint(x: CGFloat(p.x) * rect.size.width, y: CGFloat(p.y) * rect.size.height)
    }
}
//scaleToRect

func getSinusoidalPoints(n:Int) -> [SIMD2<Double>]{
    
    (0..<n).map {
        Double($0)/Double(n-1)
    }.map {
        let theta = 2.0 * $0 * .pi
        let y = 0.5 + 0.5 * sin(theta)
        return SIMD2<Double>($0, y )
    }
}

func getSinusoidalPoints(n:Int, in rect:CGRect) -> [SIMD2<Double>]{
    getSinusoidalPoints(n: n).map(scaleToRect(rect))
}
