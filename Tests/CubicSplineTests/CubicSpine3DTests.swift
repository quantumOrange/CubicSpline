//
//  CubicSpine3DTests.swift
//  
//
//  Created by David Crooks on 11/06/2023.
//

import XCTest
@testable import CubicSpline

func getSpiralPoints(n:Int) -> [SIMD3<Double>]{
    (0..<n).map {
        Double($0)/Double(n-1)
    }.map {
        // go around twice:
        let theta = 4.0 * $0 * .pi
        let x =  cos(theta)
        let y = $0
        let z = sin(theta)
        
        return SIMD3<Double>(x, y, z)
    }
}

final class CubicSpine3DTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testToFromSIMD() {
        
        let points = getSpiralPoints(n:10)
        
        let newPoints = points.toDoubleArray().toSIMD3Array()
        
        for (p,q) in zip(points,newPoints) {
            XCTAssertEqual(p.x, q.x)
            XCTAssertEqual(p.y, q.y)
            XCTAssertEqual(p.z, q.z)
        }
    }
   
  
    func testSpline() {
        
        let points = getSpiralPoints(n:10)
        
        let spline = CubicSpline3D(points:points)
        
        XCTAssert(spline.cubicCurves.count == points.count - 1, " \(spline.cubicCurves.count) != \(points.count) -1")
        let pieces = spline.cubicCurves
        
        let first = pieces.first!
        let last = pieces.last!
        
        let s = first.f(0)
        let e = last.f(1)
        
        let accuracy = 0.01
        
        XCTAssertEqual(s.x, points.first!.x, accuracy: accuracy)
        XCTAssertEqual(s.y, points.first!.y, accuracy: accuracy)
        XCTAssertEqual(e.x, points.last!.x,  accuracy: accuracy)
        XCTAssertEqual(e.y, points.last!.y,  accuracy: accuracy)
        
        var previous:CubicCurve3D?
        
        // Positions should agree at the endpoints of the pieces
        for piece in pieces {
            if let pre = previous {
                XCTAssertEqual(pre.f(1).x, piece.f(0).x, accuracy:accuracy)
                XCTAssertEqual(pre.f(1).y, piece.f(0).y, accuracy:accuracy)
                XCTAssertEqual(pre.f(1).z, piece.f(0).z, accuracy:accuracy)
            }
            previous = piece
        }
        
        // Derivitives should agree at the endpoints of the pieces
        previous = nil
        for piece in pieces {
            if let pre = previous {
                XCTAssertEqual(pre.df(1).x, piece.df(0).x, accuracy:accuracy)
                XCTAssertEqual(pre.df(1).y, piece.df(0).y, accuracy:accuracy)
                XCTAssertEqual(pre.df(1).z, piece.df(0).z, accuracy:accuracy)
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
            }
            previous = piece
        }
 
    }

}


