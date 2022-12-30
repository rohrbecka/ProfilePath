//
//  File.swift
//  
//
//  Created by André Rohrbeck on 15.09.22.
//

import Foundation
import CoreGraphics

extension CGPoint {

    // MARK: Initialisation
    /// Creates a new CGPoint based on the given `xyTuple`.
    ///
    /// This method helps shorten the code, where many points are used by omitting x and y argument labels.
    public init (_ xyTuple: (CGFloat, CGFloat)) {
        self.init(x: xyTuple.0, y: xyTuple.1)
    }
}



// MARK: Point Arithmetic

extension CGPoint {
    /// Summarizes two `CGPoint`s.
    ///
    /// Both co-ordinates are summarized.
    /// - Parameter lhs: The first point.
    /// - Parameter rhs: The second point.
    /// - Returns The point obtained by summarizing the x and y co-ordinates of both points.
    public static func + (lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        CGPoint(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
    }



    /// Multiplies a `CGPoint` with a constant value.
    ///
    /// Geometrically this corresponds to augmenting the distance of the point to the center of
    /// the co-ordinate system by the given factor.
    ///
    /// Both co-ordinates are multiplied with the `factor`.
    /// - Parameter point: The point to scale.
    /// - Parameter factor: The factor  by which to scale the point
    /// - Returns The point obtained by scaling the `point` by the `factor`.
    public static func * (point: CGPoint, factor: Double) -> CGPoint {
        CGPoint(x: point.x * factor, y: point.y * factor)
    }



    /// Divides a `CGPoint` by a constant value.
    ///
    /// Geometrically this corresponds to reducing the distance of the point to the center of
    /// the co-ordinate system by the given divisor.
    ///
    /// Both co-ordinates are divided by `divisor`.
    /// - Parameter point: The point to scale.
    /// - Parameter divisor: The divisor  by which to scale the point.
    /// - Returns The point obtained by scaling the `point` by the `factor`.
    public static func / (point: CGPoint, divisor: Double) -> CGPoint {
        point * (1.0/divisor)
    }
}


// MARK: Geometric Calculations
extension CGPoint {
    public func distance(to otherPoint: CGPoint) -> CGFloat {
        let ydist = otherPoint.y - y
        let xdist = otherPoint.x - x
        return sqrt(xdist * xdist + ydist * ydist)
    }
}



extension CGPoint: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(x)
        hasher.combine(y)
    }
}
