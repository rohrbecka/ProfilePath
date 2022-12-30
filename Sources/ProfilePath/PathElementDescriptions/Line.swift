//
//  Line.swift
//  
//
//  Created by André Rohrbeck on 15.09.22.
//

import Foundation


/// The description of a straight Line within a `Path` description.
///
/// The line description may consist of several boudary conditions. A line is uniquely described by a start and an
/// end point. In some cases it may also enough to give less information, e.g. only the end point,
/// where the line is appended directly to a precedent element with a defined end point.
/// ``Line`` is therefore relying on ``PathBuilder`` tp generate a path out of it.
/// Therefore, a ``Line`` description can't be 'incomplete' only within the context given by the other Path elements
/// it may be insufficient to be uniquely defined, which may prevent rendering.
public struct Line: PathElementDescription {

    /// The starting point.
    public var start: CGPoint?

    /// The end point.
    public var end: CGPoint?

    /// The direction of the line
    public var heading: Angle?

    /// Creates a new ``Line``.
    /// - Parameter from: The starting point.
    /// - Parameter to: The end point.
    public init (from: (CGFloat, CGFloat)? = nil, to end: (CGFloat, CGFloat)? = nil) {
        if let from {
            self.start = CGPoint(x: from.0, y: from.1)
        }
        if let end {
            self.end = CGPoint(x: end.0, y: end.1)
        }
    }


    private init(from start: CGPoint?, to end: CGPoint?, heading: Angle?) {
        self.start = start
        self.end = end
        self.heading = heading
    }


    public init(_ heading: Angle) {
        self.heading = heading
    }



    public init(_ heading: Angle, to end: (CGFloat, CGFloat)) {
        self.heading = heading
        self.end = CGPoint(x: end.0, y: end.1)
    }


    public init(from: (CGFloat, CGFloat), _ heading: Angle) {
        self.start = CGPoint(x: from.0, y: from.1)
        self.heading = heading
    }


    public var isCompletelyDefined: Bool {
        start != nil && end != nil
    }


    private var inverseHeading: Angle? {
        guard let heading else {
            return nil
        }
        return heading + Angle(degrees: 180)
    }


    public var reversed: PathElementDescription {
        Line(from: end, to: start, heading: inverseHeading)
    }
}
