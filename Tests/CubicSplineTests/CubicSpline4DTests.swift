//
//  CubicSplineNd.swift
//  
//
//  Created by David Crooks on 09/02/2024.
//

import XCTest
@testable import CubicSpline

func get4DSpiralPoints(n:Int) -> [SIMD4<Double>]{
    (0..<n).map {
        Double($0)/Double(n-1)
    }.map {
        // go around twice:
        let theta = 4.0 * $0 * .pi
        let x =  cos(theta)
        let y = $0
        let z = sin(theta)
        let w = 0.5*sin(2*theta)
        return SIMD4<Double>(x, y, z,w)
    }
}


final class CubicSpline4DTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    
    func testToFromSIMD() {
        
        let points = get4DSpiralPoints(n:10)
        
        let doubles = SIMD4.toDoubleArray(array: points)
        let newPoints = SIMD4.toSIMDArray(array: doubles)
        
        for (p,q) in zip(points,newPoints) {
            XCTAssertEqual(p, q)
        }
    }
   
    func testSpline() {
        let points = get4DSpiralPoints(n:10)
        let spline = CubicSpline(points: points)
        
        let accuracy = 0.01
        let pieces = spline.cubicCurves
        
        var previous:CubicCurve<SIMD4<Double>>?
        
        // Positions should agree at the endpoints of the pieces
        for piece in pieces {
            if let pre = previous {
                XCTAssertEqual(pre.f(1).x, piece.f(0).x, accuracy:accuracy)
                XCTAssertEqual(pre.f(1).y, piece.f(0).y, accuracy:accuracy)
                XCTAssertEqual(pre.f(1).z, piece.f(0).z, accuracy:accuracy)
                XCTAssertEqual(pre.f(1).w, piece.f(0).w, accuracy:accuracy)
            }
            previous = piece
        }
        
        previous = nil
        for piece in pieces {
            if let pre = previous {
                XCTAssertEqual(pre.df(1).x, piece.df(0).x, accuracy:accuracy)
                XCTAssertEqual(pre.df(1).y, piece.df(0).y, accuracy:accuracy)
                XCTAssertEqual(pre.df(1).z, piece.df(0).z, accuracy:accuracy)
                XCTAssertEqual(pre.df(1).w, piece.df(0).w, accuracy:accuracy)
            }
            previous = piece
        }
        
        // Second derivitives should agree at the endpoints of the pieces
        previous = nil
        for piece in pieces {
            if let pre = previous {
                XCTAssertEqual(pre.ddf(1).x, piece.ddf(0).x, accuracy:accuracy)
                XCTAssertEqual(pre.ddf(1).y, piece.ddf(0).y, accuracy:accuracy)
                XCTAssertEqual(pre.ddf(1).z, piece.ddf(0).z, accuracy:accuracy)
                XCTAssertEqual(pre.ddf(1).w, piece.ddf(0).w, accuracy:accuracy)
            }
            previous = piece
        }
    }
   
}
