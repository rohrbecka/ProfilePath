//
//  ArcElementTests.swift
//  
//
//  Created by André Rohrbeck on 23.09.22.
//

import XCTest
@testable import ProfilePath

final class ArcElementTests: XCTestCase {

    internal func testConstruction() {
        let sut0 = ArcElement(center: CGPoint(x: 1.0, y: 2.0),
                              radius: 3.0,
                              startAngle: Angle(degrees: 0.0),
                              endAngle: Angle(degrees: 90.0),
                              negativeDirection: true)

        let sut1 = ArcElement(center: CGPoint(x: 0.0, y: 0.0),
                              radius: sqrt(2),
                              startAngle: Angle(degrees: 45.0),
                              endAngle: Angle(degrees: 315.0))

        XCTAssertEqual(sut0.center, CGPoint(x: 1.0, y: 2.0))
        XCTAssertEqual(sut0.radius, 3.0)
        XCTAssertEqual(sut0.startAngle, Angle(degrees: 0.0))
        XCTAssertEqual(sut0.endAngle, Angle(degrees: 90.0))
        XCTAssertEqual(sut0.negativeDirection, true)


        XCTAssertEqual(sut1.center, CGPoint(x: 0.0, y: 0.0))
        XCTAssertEqual(sut1.radius, sqrt(2))
        XCTAssertEqual(sut1.startAngle, Angle(degrees: 45.0))
        XCTAssertEqual(sut1.endAngle, Angle(degrees: 315.0))
        XCTAssertEqual(sut1.negativeDirection, false)

    }



    func testStartAndEndGivenArcElementWithAngles() {
        let sut0 = ArcElement(center: CGPoint(x: 0, y: 0),
                              radius: 5,
                              startAngle: Angle(degrees: 0),
                              endAngle: Angle(degrees: 90))
        XCTAssert(sut0.start.distance(to: CGPoint(x: 5, y: 0)) < 0.0000001)
        XCTAssert(sut0.end.distance(to: CGPoint(x: 0, y: 5)) < 0.0000001)

        let sut1 = ArcElement(center: CGPoint(x: 3, y: -3),
                              radius: 10,
                              startAngle: Angle(degrees: 90),
                              endAngle: Angle(degrees: 180))
        XCTAssert(sut1.start.distance(to: CGPoint(x: 3, y: 7)) < 0.0000001)
        XCTAssert(sut1.end.distance(to: CGPoint(x: -7, y: -3)) < 0.0000001)
    }



    func testAngularLength() {
        let positiveDirectionArc = ArcElement(center: CGPoint(x: 0, y: 0),
                                              radius: 2.0,
                                              startAngle: Angle(degrees: 180.0),
                                              endAngle: Angle(degrees: 20.0))
        XCTAssertEqual(positiveDirectionArc.angularLength(to: CGPoint(x: 0, y: 2)).degrees, 270.0)

        let negativeDirectionArc = ArcElement(center: CGPoint(x: 0, y: 0),
                                              radius: 2.0,
                                              startAngle: Angle(degrees: 90.0),
                                              endAngle: Angle(degrees: 20.0),
                                               negativeDirection: true)
        XCTAssertEqual(negativeDirectionArc.angularLength(to: CGPoint(x: -2, y: 0)).degrees, 270.0)
    }
}
