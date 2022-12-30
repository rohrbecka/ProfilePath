//
//  Arc.swift
//  
//
//  Created by André Rohrbeck on 15.09.22.
//

import Foundation

/// The description of an Arc within a `Path` description.
///
/// The arc description may consist of several boundary conditions. Where an arc can be uniquely described
/// by a start end end angle, a direction and a radius, it may be good enough to give less information.
/// ``Arc`` allows a client to do so, and relies on the ``PathBuilder`` to generate the path out of it.
/// Therefore, an ``Arc`` description can't be 'incomplete' only within the context given by the other Path elements
/// it may be insufficient to be uniquely defined, which may prevent rendering.
public struct Arc: PathElementDescription {

    /// The radius of the arc, which must be given.
    var radius: CGFloat

    /// The center of the arc.
    var center: CGPoint?

    var startAngle: Angle?

    var endAngle: Angle?

    /// The starting point.
    var start: CGPoint?

    /// The ending point.
    var end: CGPoint?

    /// The x-coordinate of the endpoint.
    var toX: CGFloat?


    var fromX: CGFloat?

    /// Whether the arc is drawn in negative (clockwise) or positive (counterclockwise) direction.
    var negativeDirection: Bool

    /// The y-coordinate of the center.
    var centerY: CGFloat?


    /// Describes an arc based on the starting point, the x-coordinate of the end point, the center and the radius.
    ///
    /// - Parameters:
    ///   - center: The center of the arc.
    ///   - start: The starting point
    ///   - endX: The x-coordinate of the ending point
    ///   - direction: The direction in which the arc is drawn.
    public init(center: (CGFloat, CGFloat),
                from start: (CGFloat, CGFloat),
                toX endX: CGFloat,
                _ direction: Direction) {
        self.center = CGPoint(center)
        self.start = CGPoint(start)
        self.radius = CGPoint(center).distance(to: CGPoint(start))
        self.toX = endX
        self.negativeDirection = direction == .clockwise
    }



    /// Creates an Arc with a given radius going in the given `direction` until the given X-coordinate.
    /// For this to work there must be a previous element with a given end point and end directon. The
    /// new Arc will attach tangentially to the previous path element.
    public init(radius: CGFloat,
                toX endX: CGFloat,
                _ direction: Direction) {
        self.radius = radius
        self.toX = endX
        self.negativeDirection = direction == .clockwise
    }


    public init(radius: CGFloat, _ direction: Direction) {
        self.radius = radius
        self.negativeDirection = direction == .clockwise
    }



    public init(radius: CGFloat, fromX: CGFloat, _ direction: Direction) {
        self.radius = radius
        self.fromX = fromX
        self.negativeDirection = direction == .clockwise
    }


    public init(center: (CGFloat, CGFloat),
                fromX: CGFloat,
                to end: (CGFloat, CGFloat),
                _ direction: Direction) {
        self.radius = CGPoint(center).distance(to: CGPoint(end))
        self.center = CGPoint(center)
        self.fromX = fromX
        self.end = CGPoint(x: end.0, y: end.1)
        self.negativeDirection = direction == .clockwise
    }


    public init(radius: CGFloat, centerY: Double, _ direction: Direction) {
        self.radius = radius
        self.negativeDirection = direction == .clockwise
        self.centerY = centerY
    }


    public init(radius: CGFloat, _ direction: Direction, to endAngle: Angle) {
        self.radius = radius
        self.negativeDirection = direction == .clockwise
        self.endAngle = endAngle
    }


    public init(radius: CGFloat, fromHeading: Angle, _ direction: Direction) {
        self.radius = radius
        self.negativeDirection = direction == .clockwise
        self.startAngle = negativeDirection
            ? fromHeading + Angle(degrees: 90)
            : fromHeading - Angle(degrees: 90)
    }


    public init(radius: CGFloat, _ direction: Direction, toHeading: Angle) {
        self.radius = radius
        self.negativeDirection = direction == .clockwise
        self.endAngle = negativeDirection
            ? toHeading + Angle(degrees: 90)
            : toHeading - Angle(degrees: 90)
    }



    public init(radius: CGFloat, center: (CGFloat, CGFloat), _ direction: Direction) {
        self.radius = radius
        self.negativeDirection = direction == .clockwise
        self.center = CGPoint(x: center.0, y: center.1)
    }



    public static func endPoint(center: CGPoint,
                                radius: CGFloat,
                                start: CGPoint,
                                toX: CGFloat,
                                negativeDirection: Bool ) -> CGPoint {
        // swiftlint:disable identifier_name
        let dx = toX - center.x
        let targetAngle0 = acos(dx / radius)
        let targetAngle1 = -targetAngle0
        let startAngle = Sampler.angle(of: start, inRespectTo: center)
        let directionFactor = negativeDirection ? -1.0 : 1.0
        let distanceToTarget0 = (directionFactor * (targetAngle0 - startAngle)).normalised(0.0..<Double.pi)
        let distanceToTarget1 = (directionFactor * (targetAngle1 - startAngle)).normalised(0.0..<Double.pi)

        if distanceToTarget0 <= distanceToTarget1 {
            return GeometricCalculations.circlePoint(center: center, radius: radius, angle: targetAngle0)
        } else {
            return GeometricCalculations.circlePoint(center: center, radius: radius, angle: targetAngle0)
        }
        // swiftlint:ensable identifier_name
    }



    public var isCompletelyDefined: Bool {
        // the radius of the arc as well as the direction is always defined!
        center != nil
    }



    private init(radius: CGFloat,
                 center: CGPoint?,
                 startAngle: Angle?,
                 endAngle: Angle?,
                 start: CGPoint?,
                 end: CGPoint?,
                 fromX: CGFloat?,
                 toX: CGFloat?,
                 negativeDirection: Bool,
                 centerY: CGFloat?) {
        self.radius = radius
        self.center = center
        self.startAngle = startAngle
        self.endAngle = endAngle
        self.start = start
        self.end = end
        self.toX = toX
        self.negativeDirection = negativeDirection
        self.centerY = centerY
    }


    public var reversed: PathElementDescription {
        return Arc(radius: radius,
                   center: center,
                   startAngle: endAngle,
                   endAngle: startAngle,
                   start: end,
                   end: start,
                   fromX: toX,
                   toX: fromX,
                   negativeDirection: !negativeDirection,
                   centerY: centerY)
    }
}
