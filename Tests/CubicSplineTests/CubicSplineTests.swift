import XCTest
@testable import CubicSpline


class CubicSplineTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
   
  
    func testSpline() {
        
        let points = getSinusoidalPoints(n:10)
        
        let spline = CubicSpline(points:points)
        
        XCTAssert(spline.segments.count == points.count - 1, " \(spline.segments.count) != \(points.count) -1")
        let pieces = spline.segments
        
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
        
        //Positions should agree at the endpoints of the pieces
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
    
    func testPerformanceCubicSpline100() throws {
        let points = getSinusoidalPoints(n:100)
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
    
    
    // Commented out becuase this test takes quite a while
    func testPerformanceCubicSpline1000000() throws {
        let points = getSinusoidalPoints(n:1000000)
        self.measure {
            let _ = CubicSpline(points:points)
        }
    }
    
}
