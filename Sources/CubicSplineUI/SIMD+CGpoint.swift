//
//  SIMD2+CGPoint.swift
//  
//
//  Created by David Crooks on 25/02/2023.
//

import Foundation
import CoreGraphics

extension SIMD2 where Scalar==Double {
    var cgPoint:CGPoint {
        CGPoint(x: x, y: y)
    }
}
