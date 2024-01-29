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

let knotEmbedding:[SIMD3<Double>] = [
    [-0.312,0.150,-0.356],
    [-0.425,0.150,-0.046],
    [-0.327,-0.150,0.195],
    [-0.267,-0.000,0.278],
    [-0.180,0.150,0.359],
    [-0.024,0.000,0.448],
    [0.123,-0.150,0.359],
    [0.197,-0.000,0.278],
    [0.277,0.150,0.166],
    [0.357,0.075,-0.094],
    [0.267,-0.075,-0.366],
    [-0.018,-0.150,-0.383],
    [-0.106,-0.000,-0.219],
    [-0.017,0.150,-0.068],
    [0.130,0.000,0.046],
    [0.277,-0.150,0.166],
    [0.372,-0.075,0.312],
    [0.267,0.075,0.416],
    [0.123,0.150,0.359],
    [-0.020,0.000,0.259],
    [-0.180,-0.150,0.359],
    [-0.332,-0.075,0.417],
    [-0.415,0.075,0.324],
    [-0.327,0.150,0.195],
    [-0.148,0.000,0.063],
    [-0.017,-0.150,-0.068],
    [0.068,-0.000,-0.233],
    [-0.018,0.150,-0.383]
]

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
        
        let spline = CubicSpline(points:points)
        
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
        
        var previous:CubicCurve<SIMD3<Double>>?
        
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

    func testClosedLoopSpline()  {
        closedSplineTests(points:knotEmbedding)
    }
    
        
    func closedSplineTests(points:[SIMD3<Double>])  {
        
        let spline = CubicSpline<SIMD3<Double>>(points:points,closed: true)
      
        
        XCTAssert(spline.cubicCurves.count == points.count , " \(spline.cubicCurves.count) != \(points.count) ")
        var pieces = spline.cubicCurves
        
        guard let first = pieces.first, let last = pieces.last else {XCTAssert(false); return }
       
        
        let start = first.f(0)
        let end = last.f(1)
        
        let accuracy = 0.01
        
        XCTAssertEqual(start.x, points.first!.x, accuracy: accuracy)
        XCTAssertEqual(start.y, points.first!.y, accuracy: accuracy)
        
        XCTAssertEqual(end.x, start.x,  accuracy: accuracy)
        XCTAssertEqual(end.y, start.y,  accuracy: accuracy)
        
        var previous:CubicCurve<SIMD3<Double>>?
        
        // Because the spline is closed, we also need to check that the start of the first cublic curve matches position and derivitives of the last cubic curve. To this end, we append the first curve to the end of the array.
        pieces.append(first)
        
        // Positions should agree at the endpoints of the pieces
        for piece in pieces {
            if let pre = previous {
                XCTAssertEqual(pre.f(1).x, piece.f(0).x, accuracy:accuracy)
                XCTAssertEqual(pre.f(1).y, piece.f(0).y, accuracy:accuracy)
            }
            previous = piece
        }
        
        // Derivitives should agree at the endpoints of the pieces
        previous = nil
        for piece in pieces {
            if let pre = previous {
                XCTAssertEqual(pre.df(1).x, piece.df(0).x, accuracy:accuracy)
                XCTAssertEqual(pre.df(1).y, piece.df(0).y, accuracy:accuracy)
            }
            previous = piece
        }
        
        // Second derivitives should agree at the endpoints of the pieces
        previous = nil
        for piece in pieces {
            if let pre = previous {
                XCTAssertEqual(pre.ddf(1).x, piece.ddf(0).x, accuracy:accuracy)
                XCTAssertEqual(pre.ddf(1).y, piece.ddf(0).y, accuracy:accuracy)
            }
            previous = piece
        }
    }
    
}


