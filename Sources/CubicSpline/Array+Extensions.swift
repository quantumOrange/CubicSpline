//
//  Array+Extensons.swift
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
    
    func toSIMD3Array() -> [SIMD3<Double>] {
        let m = self.count/3
        let leftSplit = self[0 ..< m]
        let middleSplit = self[m ..< 2*m]
        let rightSplit = self[2*m ..< self.count]
        
        
        return zip(leftSplit,zip(middleSplit,rightSplit)).map { SIMD3<Double>($0.0,$0.1.0,$0.1.1) }
    }
}

extension Array where Element==SIMD2<Double> {
    func toDoubleArray() -> [Double] {
        map { $0.x } + map { $0.y }
    }
}

extension Array where Element==SIMD3<Double> {
    func toDoubleArray() -> [Double] {
        map { $0.x } + map { $0.y } + map { $0.z }
    }
}

extension Array where Element==CubicCurve {
    var endPoints:[SIMD2<Double>] {
        guard let last = last else {return []}
        var points = map { $0.start }
        points.append(last.end)
        return points
    }
}


extension Array where Element==CubicCurve3D {
    var endPoints:[SIMD3<Double>] {
        guard let last = last else {return []}
        var points = map { $0.start }
        points.append(last.end)
        return points
    }
}

extension Array {
    func adjacentPairs()  ->  Zip2Sequence<[Element], Array<Element>.SubSequence> {
        zip(self, self.dropFirst())
    }
}

