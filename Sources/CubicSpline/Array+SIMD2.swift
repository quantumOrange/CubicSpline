//
//  Array+SIMD2.swift
//  Spline
//
//  Created by David Crooks on 16/07/2021.
//

import Foundation

extension Array where Element==Double {
    func toSIMD2Array() -> [SIMD2<Double>] {
        let half = self.count/2
        let leftSplit = self[0 ..< half]
        let rightSplit = self[half ..< self.count]
        return zip(leftSplit,rightSplit).map { SIMD2<Double>($0.0,$0.1) }
    }
}

extension Array where Element==SIMD2<Double> {
    func toDoubleArray() -> [Double] {
        map { $0.x } + map { $0.y }
    }
}
