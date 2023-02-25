//
//  Array+Bounds.swift
//  
//
//  Created by David Crooks on 25/02/2023.
//

import Foundation
import SwiftUI

extension Array where Element==CGPoint {
    public var bounds:CGRect {
        let xs = map{ $0.x }
        let ys = map{ $0.y }
        guard let minX = xs.min(),let maxX = xs.max(),let minY = ys.min(),let maxY = ys.max() else { return CGRect.zero }
        
        return CGRect(x: minX, y: minY, width: maxX-minX, height: maxY-minY)
    }
}

extension Array where Element==CGPoint {
    @available(macOS 10.15, *)
    func pathOfDots(radius:Double) -> Path {
        var path = Path()
        
        for p in self {
            let rect = CGRect(x: p.x - radius, y: p.y - radius, width: 2*radius, height: 2*radius)
            let newPath = Path(ellipseIn: rect)
            path.addPath(newPath)
        }
        
        return path
    }
}
