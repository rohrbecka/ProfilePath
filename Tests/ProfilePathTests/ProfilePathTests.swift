//
//  ProfilePathTests.swift
//  
//
//  Created by André Rohrbeck on 27.08.22.
//

import XCTest
@testable import ProfilePath

final class ProfilePathTests: XCTestCase {


    func testPathWithThreeSimpleLines() {
        let sut = Path {
            Line(from: (0, 0), to: (20, 0))
            Line(to: (20, 10))
            Line(from: (25, 10), to: (0, 10))
        }

        if sut.elements.count == 3 {
            XCTAssertEqual(sut.elements[0] as? LineElement,
                           LineElement(start: CGPoint(x: 0, y: 0), end: (CGPoint(x: 20, y: 0))))
            XCTAssertEqual(sut.elements[1] as? LineElement,
                           LineElement(start: CGPoint(x: 20, y: 0), end: (CGPoint(x: 20, y: 10))))
            XCTAssertEqual(sut.elements[2] as? LineElement,
                           LineElement(start: CGPoint(x: 20, y: 10), end: (CGPoint(x: 0, y: 10))))
        } else {
            XCTFail("Wrong number of elements. Expected 3, got \(sut.elements.count)")
        }
    }



    func testGivenTwoIntersectingLines_IntermediatePointIsCorrectlyCalculated() {
        let sut = Path {
            Line(from: (0, 0), to: (20, 0))
            Line(from: (10, -10), to: (10, 10))
        }
        // expected result goes from (0, 0) to (10, 0) and to (10, 10)

        if sut.elements.count == 2 {
            XCTAssertEqual(sut.elements[0] as? LineElement,
                           LineElement(start: CGPoint(x: 0, y: 0), end: (CGPoint(x: 10, y: 0))))
            XCTAssertEqual(sut.elements[1] as? LineElement,
                           LineElement(start: CGPoint(x: 10, y: 0), end: (CGPoint(x: 10, y: 10))))
        } else {
            XCTFail("Wrong number of elements. Expected 2, got \(sut.elements.count).")
        }
    }



    func testTwoLinesConnectedWithFillet() {
        let sut = Path {
            Line(from: (10, 10), to: (20, 10))
            Fillet(radius: 5.0)
            Line(from: (20, 10), to: (20, 20))
        }

        if sut.elements.count == 3 {
            XCTAssertEqual(sut.elements[0] as? LineElement,
                           LineElement(start: CGPoint(x: 10, y: 10), end: CGPoint(x: 15, y: 10)))
            XCTAssertEqual(sut.elements[1] as? ArcElement,
                           ArcElement(center: CGPoint(x: 15.0, y: 15.0),
                                      radius: 5.0,
                                      start: CGPoint(x: 15, y: 10),
                                      end: CGPoint(x: 20, y: 15)))
            XCTAssertEqual(sut.elements[2] as? LineElement,
                           LineElement(start: CGPoint(x: 20, y: 15), end: CGPoint(x: 20, y: 20)))
        } else {
            XCTFail("Wrong number of elements. Expected 3, got \(sut.elements.count).")
        }
    }

}



extension LineElement: Equatable {
    public static func == (lhs: LineElement, rhs: LineElement) -> Bool {
        lhs.start.distance(to: rhs.start) < 0.00000001 &&
        lhs.end.distance(to: rhs.end) < 0.00000001
    }
}
