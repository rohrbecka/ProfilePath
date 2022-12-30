//
//  GeometricCalculationTests.swift
//  
//
//  Created by André Rohrbeck on 27.08.22.
//

import XCTest
@testable import ProfilePath

final class GeometricCalculationTests: XCTestCase {

    func testIntersectionGivenTwoPerpendicularLines () {
        let line0 = LineElement(start: CGPoint(x: 10, y: 20), end: CGPoint(x: 10, y: 40))
        let line1 = LineElement(start: CGPoint(x: 0, y: 30), end: CGPoint(x: 30, y: 30))

        let result = try? GeometricCalculations.intersection(line0, line1)

        XCTAssertEqual(CGPoint(x: 10, y: 30), result?.point)
    }



    func testIntersectionGivenTwoDiagonalLines () {
        let line0 = LineElement(start: CGPoint(x: 0, y: 0), end: CGPoint(x: 40, y: 30))
        let line1 = LineElement(start: CGPoint(x: 0, y: 30), end: CGPoint(x: 40, y: 0))

        let result = try? GeometricCalculations.intersection(line0, line1)

        XCTAssertEqual(CGPoint(x: 20, y: 15), result?.point)
    }



    func testIntersectionsGivingCircleAndVerticalLine() {
        let circle = Circle(center: CGPoint(x: 3, y: 2), radius: 1)
        let verticalLine0 = LineElement(start: CGPoint(x: 1.9, y: 0), end: CGPoint(x: 1.9, y: 20))
        let verticalLine1 = LineElement(start: CGPoint(x: 2.0, y: 0), end: CGPoint(x: 2.0, y: 20))
        let verticalLine2 = LineElement(start: CGPoint(x: 3.0, y: 0), end: CGPoint(x: 3.0, y: 20))
        let verticalLine3 = LineElement(start: CGPoint(x: 4.1, y: 0), end: CGPoint(x: 4.1, y: 20))

        XCTAssertThrowsError(try GeometricCalculations.intersectionPoints(circle, verticalLine0))
        XCTAssertEqual(try? GeometricCalculations.intersectionPoints(circle, verticalLine1), [CGPoint(x: 2.0, y: 2.0)])
        XCTAssertEqual(try? GeometricCalculations.intersectionPoints(circle, verticalLine2),
                       [CGPoint(x: 3.0, y: 1.0), CGPoint(x: 3.0, y: 3.0)])
        XCTAssertThrowsError(try GeometricCalculations.intersectionPoints(circle, verticalLine3))
    }


    func testIntersectionsGivingCircleAndHorizontalLine() {
        let circle = Circle(center: CGPoint(x: -3, y: -2), radius: 1)
        let horizontalLine0 = LineElement(start: CGPoint(x: 0, y: -0.9), end: CGPoint(x: 20, y: -0.9))
        let horizontalLine1 = LineElement(start: CGPoint(x: 0, y: -1), end: CGPoint(x: 20, y: -1))
        let horizontalLine2 = LineElement(start: CGPoint(x: 0, y: -2), end: CGPoint(x: 20, y: -2))
        let horizontalLine3 = LineElement(start: CGPoint(x: 0, y: -3.1), end: CGPoint(x: 20, y: -3.1))

        XCTAssertThrowsError(try GeometricCalculations.intersectionPoints(circle, horizontalLine0))
        XCTAssertEqual(try? GeometricCalculations.intersectionPoints(circle, horizontalLine1),
                       [CGPoint(x: -3.0, y: -1.0)])
        XCTAssertEqual(try? GeometricCalculations.intersectionPoints(circle, horizontalLine2),
                       [CGPoint(x: -4.0, y: -2.0), CGPoint(x: -2.0, y: -2.0)])
        XCTAssertThrowsError(try GeometricCalculations.intersectionPoints(circle, horizontalLine3))
    }


    func testParallelGivenHorizontalLine() {
        let horizontalLine = LineElement(start: CGPoint(x: 0, y: 0), end: CGPoint(x: 20, y: 0))
        let leftParallel = GeometricCalculations.parallel(to: horizontalLine, distance: -5)
        let rightParallel = GeometricCalculations.parallel(to: horizontalLine, distance: 3)

        XCTAssertEqual(leftParallel.start, CGPoint(x: 0, y: 5))
        XCTAssertEqual(leftParallel.end, CGPoint(x: 20, y: 5))

        XCTAssertEqual(rightParallel.start, CGPoint(x: 0, y: -3))
        XCTAssertEqual(rightParallel.end, CGPoint(x: 20, y: -3))
    }



    func testParallelGivenVerticalLine() {
        let horizontalLine = LineElement(start: CGPoint(x: 0, y: 0), end: CGPoint(x: 0, y: -20))
        let leftParallel = GeometricCalculations.parallel(to: horizontalLine, distance: -1)
        let rightParallel = GeometricCalculations.parallel(to: horizontalLine, distance: 2)

        XCTAssertEqual(leftParallel.start, CGPoint(x: 1, y: 0))
        XCTAssertEqual(leftParallel.end, CGPoint(x: 1, y: -20))

        XCTAssertEqual(rightParallel.start, CGPoint(x: -2, y: 0))
        XCTAssertEqual(rightParallel.end, CGPoint(x: -2, y: -20))
    }



    func testAngleBetweenLines() {
		let line0 = LineElement(start: CGPoint(x: 0, y: 0), end: CGPoint(x: 1, y: 0))
        let line45 = LineElement(start: CGPoint(x: 0, y: 0), end: CGPoint(x: 1, y: 1))
        let line90 = LineElement(start: CGPoint(x: 0, y: 0), end: CGPoint(x: 0, y: 1))
        let line180 = LineElement(start: CGPoint(x: 2, y: 2), end: CGPoint(x: 0, y: 2))
        let line270 = LineElement(start: CGPoint(x: 1, y: 1), end: CGPoint(x: 1, y: 0))

        XCTAssertEqual(GeometricCalculations.angle(between: line0, and: line45).degrees, 45.0)
        XCTAssertEqual(GeometricCalculations.angle(between: line0, and: line90).degrees, 90.0)
        XCTAssertEqual(GeometricCalculations.angle(between: line45, and: line180).degrees, 135.0)
        XCTAssertEqual(GeometricCalculations.angle(between: line180, and: line45).degrees, 225.0)
        XCTAssertEqual(GeometricCalculations.angle(between: line0, and: line180).degrees, 180.0)
        XCTAssertEqual(GeometricCalculations.angle(between: line0, and: line270).degrees, 270)
        XCTAssertEqual(GeometricCalculations.angle(between: line270, and: line0).degrees, 90)
    }
}



extension GeometricCalculationTests {
    func testArcCenterCalculationGivenStartPointZeroHeadingAndRadius() {
        let startPoint = CGPoint(x: 0, y: 0)
        let center0 = GeometricCalculations.arcCenter(tangentiallyAppendingTo: startPoint,
                                                      heading: Angle(radians: 0),
                                                      radius: 3.0,
                                                      negativeDirection: false)
        XCTAssertEqual(center0.x, 0.0, accuracy: 0.000001)
        XCTAssertEqual(center0.y, 3.0, accuracy: 0.000001)

        let center1 = GeometricCalculations.arcCenter(tangentiallyAppendingTo: startPoint,
                                                      heading: Angle(radians: 0),
                                                      radius: 2.5,
                                                      negativeDirection: true)
        XCTAssertEqual(center1.x, 0.0, accuracy: 0.000001)
        XCTAssertEqual(center1.y, -2.5, accuracy: 0.000001)

        let center2 = GeometricCalculations.arcCenter(tangentiallyAppendingTo: startPoint,
                                                      heading: Angle(radians: Double.pi/2.0),
                                                      radius: 1.0,
                                                      negativeDirection: false)
        XCTAssertEqual(center2.x, -1.0, accuracy: 0.000001)
        XCTAssertEqual(center2.y, 0, accuracy: 0.000001)
    }
}
