//
//  CGPoint+Tests.swift
//  
//
//  Created by André Rohrbeck on 15.09.22.
//

import XCTest
import ProfilePath

internal final class CGPointTests: XCTestCase {
    internal func testInitialisationBasedOnTuple() {
        let sut0 = CGPoint((0, 0))
        let sut1 = CGPoint((4.7, 1.1))
        let sut2 = CGPoint((-0.8, 15))

        XCTAssertEqual(sut0.x, 0)
        XCTAssertEqual(sut0.y, 0)
        XCTAssertEqual(sut1.x, 4.7)
        XCTAssertEqual(sut1.y, 1.1)
        XCTAssertEqual(sut2.x, -0.8)
        XCTAssertEqual(sut2.y, 15.0)
    }
}



extension CGPointTests {
    func testAddition() {
        let point0 = CGPoint(x: 12.3, y: 45.6)
        let point1 = CGPoint(x: -7.8, y: -9.0)
        let result = point0 + point1

        let expectedResult = CGPoint(x: 4.5, y: 36.6)
        XCTAssertEqual(expectedResult.x, result.x, accuracy: 0.0000001)
        XCTAssertEqual(expectedResult.y, result.y, accuracy: 0.0000001)
    }



    func testMultiplication() {
        let point0 = CGPoint(x: 12.3, y: 45.6)
        let point1 = CGPoint(x: -7.8, y: -9.0)
        let result0 = point0 * 4
        let result1 = point1 * (-2.5)

        let expectedResult0 = CGPoint(x: 49.2, y: 182.4)
        let expectedResult1 = CGPoint(x: 19.5, y: 22.5)
        XCTAssertEqual(expectedResult0.x, result0.x, accuracy: 0.0000001)
        XCTAssertEqual(expectedResult0.y, result0.y, accuracy: 0.0000001)
        XCTAssertEqual(expectedResult1.x, result1.x, accuracy: 0.0000001)
        XCTAssertEqual(expectedResult1.y, result1.y, accuracy: 0.0000001)
    }



    func testDivision() {
        let point0 = CGPoint(x: 12.3, y: 45.6)
        let point1 = CGPoint(x: -7.8, y: -9.0)
        let result0 = point0 / 0.25
        let result1 = point1 / (-0.4)

        let expectedResult0 = CGPoint(x: 49.2, y: 182.4)
        let expectedResult1 = CGPoint(x: 19.5, y: 22.5)
        XCTAssertEqual(expectedResult0.x, result0.x, accuracy: 0.0000001)
        XCTAssertEqual(expectedResult0.y, result0.y, accuracy: 0.0000001)
        XCTAssertEqual(expectedResult1.x, result1.x, accuracy: 0.0000001)
        XCTAssertEqual(expectedResult1.y, result1.y, accuracy: 0.0000001)
    }
}
