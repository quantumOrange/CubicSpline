//
//  Array+Extensons.swift
//  Spline
//
//  Created by David Crooks on 16/07/2021.
//

import Foundation

public protocol Flattenable:SIMD {
    static func toSIMDArray(array:[Double]) -> [Self]
    static func toDoubleArray(array:[Self]) -> [Double]
}


extension SIMD2<Double>:Flattenable {
    public static func toSIMDArray( array: [Double]) -> [SIMD2<Scalar>] {
        let half = array.count/2
        let leftSplit = array[0 ..< half]
        let rightSplit = array[half ..< array.count]
        return zip(leftSplit,rightSplit).map { SIMD2<Double>($0.0,$0.1) }
    }
    
    public static func toDoubleArray(array: [SIMD2<Scalar>]) -> [Double] {
        array.map { $0.x } + array.map { $0.y }
    }
}

extension SIMD3<Double>:Flattenable {
    public static func toSIMDArray( array: [Double]) -> [SIMD3<Scalar>] {
        let m = array.count/3
        let leftSplit = array[0 ..< m]
        let middleSplit = array[m ..< 2*m]
        let rightSplit = array[2*m ..< array.count]
        
        
        return zip(leftSplit,zip(middleSplit,rightSplit)).map { SIMD3<Double>($0.0,$0.1.0,$0.1.1) }
    }
    
    public static func toDoubleArray(array: [SIMD3<Scalar>]) -> [Double] {
        array.map { $0.x } + array.map { $0.y } + array.map { $0.z }
    }
}

extension Flattenable  {
    public static func toSIMDArray( array: [Self.Scalar]) -> [Self] {
        let n = Self.scalarCount
        let m = array.count/n
        
        var simds:[Self]  = []
        
        for i in 0..<m {
            var doubles:[Self.Scalar]  = []
            for j in 0..<n {
                doubles.append(array[m*j + i])
            }
            simds.append(Self(doubles))
        }
    
        return simds
    }
    
    public static func toDoubleArray(array: [Self]) -> [Self.Scalar] {
        let n = Self.scalarCount
        var doubles:[Self.Scalar]  = []
        for i in 0..<n {
            let x = array.map { $0[i] }
            doubles.append(contentsOf: x)
            
        }
       return doubles
    }
}

extension Array where Element==Double {
    /*
    func toSIMD2Array() -> [SIMD2<Double>] {
       
        let half = self.count/2
        let leftSplit = self[0 ..< half]
        let rightSplit = self[half ..< self.count]
        return zip(leftSplit,rightSplit).map { SIMD2<Double>($0.0,$0.1) }
    }
    */
    func toSIMD3Array() -> [SIMD3<Double>] {
        let m = self.count/3
        let leftSplit = self[0 ..< m]
        let middleSplit = self[m ..< 2*m]
        let rightSplit = self[2*m ..< self.count]
        
        
        return zip(leftSplit,zip(middleSplit,rightSplit)).map { SIMD3<Double>($0.0,$0.1.0,$0.1.1) }
    }
}

extension Array where Element==SIMD2<Double> {
    /*
    func toDoubleArray() -> [Double] {
        map { $0.x } + map { $0.y }
    }
     */
}

extension Array where Element==SIMD3<Double> {
    func toDoubleArray() -> [Double] {
        map { $0.x } + map { $0.y } + map { $0.z }
    }
}


protocol CubicCurveProtocol {
    associatedtype PointType
    var start: PointType { get }
    var end: PointType { get }
}

extension  CubicCurve: CubicCurveProtocol {}

extension Array where Element: CubicCurveProtocol {
    var endPoints:[Element.PointType] {
        guard let last = last else {return []}
        var points = map { $0.start }
        points.append(last.end)
        return points
    }
}


/*
extension Array where Element==CubicCurve<SIMD3<Double>>   {
    var endPoints:[SIMD3<Double>] {
        guard let last = last else {return []}
        var points = map { $0.start }
        points.append(last.end)
        return points
    }
}
*/

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
 
    func cyclicAdjacentPairs() ->  Zip2Sequence<[Element], ArraySlice<Element>> {
        guard let first else { return adjacentPairs() }
        var arr = self
        arr.append(first)
        return arr.adjacentPairs()
    }
}
