import XCTest
@testable import CubicSpline

func getSinusoidalPoints(n:Int) -> [SIMD2<Double>]{
    (0..<n).map {
        Double($0)/Double(n-1)
    }.map {
        let theta = 2.0 * $0 * .pi
        let y = 0.5 + 0.5 * sin(theta)
        return SIMD2<Double>($0, y )
    }
}

func getCirclePoints(n:Int) -> [SIMD2<Double>]{
    (0..<n).map {
        Double($0)/Double(n-1)
    }.map {
        let theta = 2.0 * $0 * .pi
        return SIMD2<Double>(cos(theta), sin(theta) )
    }
}

class CubicSplineTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testToFromSIMD() {
        
        let points = getSinusoidalPoints(n:10)
        
        let newPoints = points.toDoubleArray().toSIMD2Array()
        
        for (p,q) in zip(points,newPoints) {
            XCTAssertEqual(p.x, q.x)
            XCTAssertEqual(p.y, q.y)
            //XCTAssertEqual(p.x, q.x)
        }
    }
  
    func testSpline() {
        
        let points = getSinusoidalPoints(n:10)
        
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
        
        var previous:CubicCurve?
        
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
    
    func testClosedSpline()  {
        
        let points = getCirclePoints(n:10)
        //do {
            let spline = CubicSpline(points:points,closed: true)
       // }
       // catch {
       //     print(error)
       //     XCTAssert(false)
       // }
        
        XCTAssert(spline.cubicCurves.count == points.count - 1, " \(spline.cubicCurves.count) != \(points.count) -1")
        let pieces = spline.cubicCurves
        
        guard let first = pieces.first, let last = pieces.last else {XCTAssert(false); return }
       
        
        let s = first.f(0)
        let e = last.f(1)
        
        let accuracy = 0.01
        
        XCTAssertEqual(s.x, points.first!.x, accuracy: accuracy)
        XCTAssertEqual(s.y, points.first!.y, accuracy: accuracy)
        XCTAssertEqual(e.x, points.last!.x,  accuracy: accuracy)
        XCTAssertEqual(e.y, points.last!.y,  accuracy: accuracy)
        
        var previous:CubicCurve?
        
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
    
    func testPerformanceCubicSpline10() throws {
        let points = getSinusoidalPoints(n:10)
        self.measure {
            let _ = CubicSpline(points:points)
        }
    }
    
    func testPerformanceCubicSpline100() throws {
        let points = getSinusoidalPoints(n:100)
        self.measure {
            let _ = CubicSpline(points:points)
        }
    }

    func testPerformanceCubicSpline1000() throws {
        let points = getSinusoidalPoints(n:1000)
        self.measure {
            let _ = CubicSpline(points:points)
        }
    }
   
    func testPerformanceCubicSpline10000() throws {
        let points = getSinusoidalPoints(n:10000)
        self.measure {
            let _ = CubicSpline(points:points)
        }
    }
    
    func testPerformanceCubicSpline100000() throws {
        let points = getSinusoidalPoints(n:100000)
        self.measure {
            let _ = CubicSpline(points:points)
        }
    }
       
}

// Performance on M1 Max Mac Pro:
// 10, 0.0000978 s
// 100, 0.000516 s
// 1000, 0.00297 s
// 10000, 0.0195 s
// 100000, 0.178 s
// 1000000,  1.77 s
