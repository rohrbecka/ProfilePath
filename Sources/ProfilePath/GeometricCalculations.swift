//
//  GeometricCalculations.swift
//  
//
//  Created by André Rohrbeck on 27.08.22.
//

import Foundation

internal enum GeometricCalculations {

// MARK: - Points:
    /// Returns the intersection point of two straight lines.
    ///
    /// - Parameters:
    ///   - line0: The first ``StraightLine``
    ///   - line1: The second ``StraightLine``
    /// - Returns: The point where the two lines intersect each other.
    /// - Throws ``GeometricCalcuationError.noIntersection`` if the lines are parallel but not identical and
    ///   ``GeometricCalculationError.identicalLines``if the lines are identical.
    internal static func intersection(_ line0: LineElement, _ line1: LineElement) throws -> Intersection {
        let intersectionPoint: CGPoint

        // swiftlint:disable identifier_name
        if line0.isVertical && line1.isVertical {
            if line0.start.x == line1.start.x {
                throw GeometricCalculationError.identicalLines
            } else {
                throw GeometricCalculationError.noIntersection
            }
        } else if line0.isVertical {
            intersectionPoint = CGPoint(x: line0.start.x, y: line1.y(atX: line0.start.x))
        } else if line1.isVertical {
            intersectionPoint = CGPoint(x: line1.start.x, y: line0.y(atX: line1.start.x))
        } else { // both lines are not vertical, use equation to find result
            // TODO: The following is a problem in cases, where m is near to inf (the line is nearly vertical)
            // in these cases, both ∆b is divided by infinity, which results in weird values for x-
            let x = (line1.b - line0.b) / (line0.m - line1.m)
            let y = line0.y(atX: x)
            intersectionPoint = CGPoint(x: x, y: y)
        }
        // swiftlint:enable identifier_name

        return Intersection(point: intersectionPoint,
                            element0: line0,
                            element1: line1,
                            angle0: line0.endHeading,
                            angle1: line1.endHeading)
    }


    /// Returns the ``Intersections`` between an ``ArcElement`` and a ``StraightLine``.
    ///
    /// There may be up to two intersections depending of the relative position of the ``PathElement``s.
    /// In the case of 0 intersections a ``noIntersection`` error is thrown.
    ///
    /// - Parameters:
    ///   - arc: The ``ArcElement``.
    ///   - line: The ``StraightLine``.
    /// - Returns: The intersections.
    /// - Throws: A ``GeometricCalculationError.noIntersection`` if there are no intersections.
    public static func intersections(_ arc: ArcElement, _ line: LineElement) throws -> [Intersection] {
        let points = Array(try intersectionPoints(Circle(arc), line))
        return points.map {
            Intersection(point: $0,
                         element0: arc,
                         element1: line,
                         angle0: arc.heading(at: $0),
                         angle1: line.endHeading)
        }
    }


    /// Returns the intersections between a ``Circle`` and a ``StraightLine``.
    ///
    /// There may be 0, 1 or 2 intersections. In the case of 0 intersections, this function throws a
    /// ``noIntersection`` error.
    /// In the case of 1 or 2 intersections, the intersections are returned as a Set of points.
    ///
    /// - Parameter circle: The ``Circle``.
    /// - Parameter line: The ``StraightLine``.
    /// - Returns The intersections between the ``line``and the ``circle``, if there are any.
    /// - Throws: A ``GeometricCalculationError.noIntersection`` if there are no intersections.
    // swiftlint:disable identifier_name
    internal static func intersectionPoints(_ circle: Circle, _ line: LineElement) throws -> Set<CGPoint> {
        let xLine = line.start.x
        let r = circle.radius
        let c = circle.center

        if line.isVertical {
            if xLine < c.x - r {
                throw GeometricCalculationError.noIntersection
            } else if xLine > c.x + r {
                throw GeometricCalculationError.noIntersection
            } else {
                let root = sqrt(r * r - (xLine - c.x) * (xLine - c.x))
                return Set([CGPoint(x: xLine, y: c.y + root),
                        CGPoint(x: xLine, y: c.y - root)])
            }
        } else {
            let m = line.m
            let b = line.b
            // quadratic equation of circe and line reduced to x and normalized (prepared for p/q-formula)
            let p = (2 * m * b - 2 * c.x - 2 * c.y * m) / (1 + m*m)
            let q = (b*b + c.x*c.x - 2*c.y*b + c.y*c.y - r*r) / (1 + m*m)

            let xValues = pqFormula(p: p, q: q)
            if xValues.isEmpty {
                throw GeometricCalculationError.noIntersection
            } else {
                return Set(xValues.map {
                    CGPoint(x: $0, y: m * $0 + b)
                })
            }
        }
    }
    // swiftlint:enable identifier_name



    /// Returns the solutions of a quadratic equation.
    ///
    /// Given a quadratic equation in the normalized form **0 = x² + px + q** returns the set of possible
    /// solutions for x. The equation may have zero, one or two solutions, which are returned as a
    /// ``Set``.
    ///
    /// - Parameter p: The linear term *p*.
    /// - Parameter q: The constant termi *q*.
    /// - Returns the solutions for x.
    // swiftlint:disable identifier_name
    private static func pqFormula(p: Double, q: Double) -> Set<Double> {
        let radix = (p/2.0) * (p/2.0) - q
        if radix < 0 {
            return Set<Double>()
        } else {
            return Set([-p/2 + sqrt(radix),
                         -p/2 - sqrt(radix)])
        }
    }
    // swiftlint:enable identifier_name



    /// Returns a line parallel to the given `line`.
    ///
    /// - Parameter line: The line to which to calculate the parallel.
    /// - Parameter distance: The distance in which the parallel shall be calculated. negative numbers are left.
    /// - Returns The line parallel to the given `line` in the given `distance`.
    // swiftlint:disable identifier_name
    internal static func parallel(to line: LineElement, distance: Double) -> LineElement {
        let dx = (line.end.y - line.start.y) / line.length * distance
        let dy = -(line.end.x - line.start.x) / line.length * distance
        let shift = CGPoint(x: dx, y: dy)
        return LineElement(start: line.start + shift, end: line.end + shift)
    }
    // swiftlint:enable identifier_name



    // swiftlint:disable identifier_name
    internal static func angle(of point: CGPoint, inRespectTo center: CGPoint) -> Angle {
        let dx = point.x - center.x
        let dy = point.y - center.y
        if dx == 0 && dy > 0 {
            return Angle(degrees: 90.0)
        } else if dx == 0 && dy < 0 {
            return Angle(degrees: 270.0)
        } else {
            let angle = atan(dy / dx)
            if dx > 0 {
                return Angle(radians: angle)
            } else {
                return Angle(radians: angle + Double.pi)
            }
        }
    }
    // swiftlint:enable identifier_name



    /// Returns the angle between the given lines, taking them as a "flight path" from `start` to `end`.
    ///
    /// The returned angle is in fact the optimum change in "heading" of the lines.
    /// - Parameter line0: The first line,
    /// - Parameter line1: The second line.
    /// - Returns: The change of heading from `line0`to `line1` given in degrees from
    ///             -180° (excluded) to 180° (included).
    internal static func angle(between line0: LineElement, and line1: LineElement) -> Angle {
        line1.heading - line0.heading
    }


    /// Returns a ``StraightLine`` which is perpendicular to the given `line` and goes through the given `point`.
    ///
    /// - Parameter line: The line to which a perpendicular line shall be calculated.
    /// - Parameter point: The point, which should be part of the perpendicular line.
    /// - Returns: The perpendicular line. The direction of the line is not defined.
    internal static func perpendicular(to line: LineElement, through point: CGPoint) -> LineElement {
        if line.isVertical {
            return LineElement(start: point, end: CGPoint(x: point.x + line.length, y: point.y))
        } else if line.isHorizontal {
            return LineElement(start: point, end: CGPoint(x: point.x, y: point.y + line.length))
        } else {
            return LineElement(start: point, end: CGPoint(x: point.x+line.length, y: point.y-1/line.m*line.length))
        }
    }



    /// Returns the ``ArcElement`` representing the fillet between two lines.
    ///
    /// - Parameters:
    ///   - line0: The first line.
    ///   - line1: The second line.
    ///   - radius: The radius of the fillet.
    /// - Returns: The fillet.
    /// - Throws: An error, if no fillet center can be found.
    internal static func fillet(_ line0: LineElement, _ line1: LineElement, radius: CGFloat) throws -> ArcElement {
        let headingChange = angle(between: line0, and: line1)
        let distance: Double
        let negativeDirection: Bool
        if headingChange.degrees <= 180 { // left
            distance = -radius
            negativeDirection = false
        } else {
            distance = radius
            negativeDirection = true
        }
        let parallel0 = parallel(to: line0, distance: distance)
        let parallel1 = parallel(to: line1, distance: distance)
        let filletCenter = try intersection(parallel0, parallel1)
        let filletStart = try intersection(line0, perpendicular(to: line0, through: filletCenter.point))
        let filletEnd = try intersection(line1, perpendicular(to: line1, through: filletCenter.point))

        return ArcElement(center: filletCenter.point,
                          radius: radius,
                          start: filletStart.point,
                          end: filletEnd.point,
                          negativeDirection: negativeDirection)
    }



    internal static func fillet(_ arc: ArcElement, _ line: LineElement, radius: Double) throws -> ArcElement {
        let parallelArc = ArcElement(center: arc.center,
                                     radius: arc.radius - radius,
                                     startAngle: arc.startAngle,
                                     endAngle: arc.endAngle)
        let parallelLine0 = parallel(to: line, distance: radius)
        let parallelLine1 = parallel(to: line, distance: -radius)

        let intersections0 = (try? intersections(parallelArc, parallelLine0)) ?? [Intersection]()
        let intersections1 = (try? intersections(parallelArc, parallelLine1)) ?? [Intersection]()

        let intersections = (intersections0 + intersections1).sorted(by: {
            arc.angularLength(to: $0.point).rad < arc.angularLength(to: $1.point).rad
        })
        if let filletCenter = intersections.first?.point {
            let startAngle = LineElement(start: arc.center, end: filletCenter).heading.rad
            let start = filletCenter + CGPoint(x: radius * cos(Double(startAngle)), y: radius * sin(Double(startAngle)))
            if let end = try? intersection(line, perpendicular(to: line, through: filletCenter)) {
                return ArcElement(center: filletCenter,
                                  radius: radius,
                                  start: start,
                                  end: end.point,
                                  negativeDirection: arc.negativeDirection)
            }
        }
        throw GeometricCalculationError.noIntersection
    }



    private static func headingChange (_ circle: Circle,
                                       _ line: LineElement,
                                       at point: CGPoint?,
                                       negativeDirection: Bool) -> Double? {
        guard let point else {
            return nil
        }
        let radiusHeading = LineElement(start: circle.center, end: point).heading
        if negativeDirection {
            return (-(line.heading.degrees - (radiusHeading.degrees - 90))).normalised(0..<360.0)
        } else {
            return (line.heading.degrees - (radiusHeading.degrees + 90)).normalised(0..<360.0)
        }
    }



    internal static func circlePoint(center: CGPoint, radius: CGFloat, angle: Double) -> CGPoint {
        CGPoint(x: center.x + radius * cos(angle),
                y: center.y + radius * sin(angle))
    }



    internal static func arcCenter(tangentiallyAppendingTo startPoint: CGPoint,
                                   heading: Angle,
                                   radius: Double,
                                   negativeDirection: Bool) -> CGPoint {
        let directionOfCenterFromStartPoint = negativeDirection ? heading.rad - Double.pi/2 : heading.rad + Double.pi/2
        let center = circlePoint(center: startPoint, radius: radius, angle: directionOfCenterFromStartPoint)
        return center
    }
}



internal enum GeometricCalculationError: Error {
    case noIntersection
    case identicalLines
}



internal struct Circle {
    var center: CGPoint
    var radius: CGFloat


    init(center: CGPoint, radius: CGFloat) {
        self.center = center
        self.radius = radius
    }


    init(_ arc: ArcElement) {
        self.center = arc.center
        self.radius = arc.radius
    }
}
