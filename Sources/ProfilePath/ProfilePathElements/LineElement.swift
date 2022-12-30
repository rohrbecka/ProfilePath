//
//  LineElement.swift
//  
//
//  Created by André Rohrbeck on 15.09.22.
//

import Foundation


/// A Straight line connecting two points.
public struct LineElement {
    /// The start point
    public var start: CGPoint

    /// The end point
    public var end: CGPoint

    /// `true` if the ``end`` is a valid end point, which may be used to append the next ``PathElement``.
    public let isEndValidEndPoint: Bool


    public init(start: CGPoint, end: CGPoint, isEndValidEndPoint: Bool = true) {
        self.start = start
        self.end = end
        self.isEndValidEndPoint = isEndValidEndPoint
    }



    public init(start: CGPoint, heading: Angle, length: CGFloat) {
        self.start = start
        self.end = CGPoint(x: start.x + cos(heading.rad) * length,
                           y: start.y + sin(heading.rad) * length)
        self.isEndValidEndPoint = false
    }



    public init(heading: Angle, length: CGFloat, end: CGPoint) {
        self.end = end
        self.start = CGPoint(x: end.x - cos(heading.rad) * length,
                             y: end.y - sin(heading.rad) * length)
        self.isEndValidEndPoint = true
    }
}



extension LineElement: PathElement {
    public var startPoint: CGPoint {
        return start
    }


    public var startHeading: Angle {
        endHeading
    }

    public var endPoint: CGPoint? {
        guard isEndValidEndPoint else {
            return nil
        }
        return end
    }


    public var endHeading: Angle {
        GeometricCalculations.angle(of: end, inRespectTo: start)
    }


    public var reversed: Self {
        LineElement(start: end, end: start)
    }
}



extension LineElement {
    var isVertical: Bool {
        abs(start.x - end.x) < 0.0000001
        //        start.x == end.x
    }


    var isHorizontal: Bool {
        start.y == end.y
    }

    // swiftlint:disable identifier_name
    var m: Double {
        (end.y - start.y) / (end.x - start.x)
    }

    var b: Double {
        start.y - m * start.x
    }

    func y(atX x: Double) -> CGFloat {
        m * x + b
    }

    var dx: Double {
        end.x - start.x
    }


    var dy: Double {
        end.y - start.y    }

    var length: Double {
        sqrt( dx * dx + dy * dy )
    }
    // swiftlint:enable identifier_name


    /// The direction of this ``StraightLine`` in degrees from 0° to 360° (excluded)
    ///
    /// 0° is defined along the x-axis, turning lieft is positive (y axis is 90°).
    var heading: Angle {
        if dx == 0 {
            if dy > 0 {
                return Angle(degrees: 90.0)
            } else {
                return Angle(degrees: 270.0)
            }
        } else {
            var angle = Angle(radians: atan(dy/dx))
            if dx < 0 {
                // swiftlint:disable:next shorthand_operator
                angle = angle + Angle(degrees: 180)
            }
            return angle
        }
    }
}
