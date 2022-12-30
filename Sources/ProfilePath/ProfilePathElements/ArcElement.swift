//
//  ArcElement.swift
//  
//
//  Created by André Rohrbeck on 15.09.22.
//

import Foundation


/// An arc with a radius from a given start to an end angle in a certain direction.
internal struct ArcElement: Equatable {
    /// The center of the arc.
    public var center: CGPoint

    /// The radius of the arc
    public var radius: CGFloat

    /// The angle at which the arc starts.
    public var startAngle: Angle

    /// The angle at which the arc ends.
    public var endAngle: Angle

    /// The direction in which the arc is drawn from start to end.
    public var negativeDirection: Bool


    /// The starting point of the  ``ArcElement``.
    public var start: CGPoint {
        CGPoint(x: cos(startAngle.rad), y: sin(startAngle.rad)) * radius + center
    }


    /// The ending point of the ``ArcElement``.
    public var end: CGPoint {
        CGPoint(x: cos(endAngle.rad), y: sin(endAngle.rad)) * radius + center
    }



    /// Creates an ``Arc`` giving it's center, radius and the start and end angle.
    public init(center: CGPoint, radius: CGFloat, startAngle: Angle, endAngle: Angle, negativeDirection: Bool = false) {
        self.center = center
        self.radius = radius
        self.startAngle = startAngle
        self.endAngle = endAngle
        self.negativeDirection = negativeDirection
    }


    /// Creates an ``Arc``giving it's center, radius and a start and end point. The start and end points
    /// are not necessarily on the arc themselves. They only define the start and end angle.
    public init(center: CGPoint, radius: CGFloat, start: CGPoint, end: CGPoint,
                negativeDirection: Bool = false) {
        self.center = center
        self.radius = radius
        self.startAngle = GeometricCalculations.angle(of: start, inRespectTo: center)
        self.endAngle = GeometricCalculations.angle(of: end, inRespectTo: center)
        self.negativeDirection = negativeDirection
    }


    /// The reversed Arc,which is obtained by swapping the start and end angle as well as the
    /// inverting the direction. The final arc is thus identical to the initial arc. The path is only traversed
    /// in the other direction.
    var reversed: Self {
        ArcElement(center: center,
                   radius: radius,
                   startAngle: endAngle,
                   endAngle: startAngle,
                   negativeDirection: !negativeDirection)
    }
}



extension ArcElement: PathElement {

    public var startPoint: CGPoint {
        start
    }


    public var startHeading: Angle {
        negativeDirection
            ? Angle(degrees: startAngle.degrees - 90)
            : Angle(degrees: startAngle.degrees + 90)
    }

    public var endPoint: CGPoint? {
        end
    }


    public var endHeading: Angle {
        negativeDirection
            ? Angle(degrees: endAngle.degrees - 90)
            : Angle(degrees: endAngle.degrees + 90)
    }
}



extension ArcElement {
    public func heading(at point: CGPoint) -> Angle {
        let angle = GeometricCalculations.angle(of: point, inRespectTo: center)
        return negativeDirection
        ? Angle(degrees: angle.degrees - 90)
        : Angle(degrees: angle.degrees + 90)
    }



    public func angularLength(to endPoint: CGPoint) -> Angle {
        let endAngle = GeometricCalculations.angle(of: endPoint, inRespectTo: center)
        let factor = negativeDirection ? -1.0 : 1.0
        return Angle(radians: factor * (endAngle.rad - startAngle.rad))
    }
}
