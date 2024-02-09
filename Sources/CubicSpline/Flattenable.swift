//
//  File.swift
//  
//
//  Created by David Crooks on 09/02/2024.
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

extension SIMD4<Double>:Flattenable {}
extension SIMD8<Double>:Flattenable {}
extension SIMD16<Double>:Flattenable {}
extension SIMD32<Double>:Flattenable {}
extension SIMD64<Double>:Flattenable {}
