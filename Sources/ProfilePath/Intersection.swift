//
//  Intersection.swift
//  
//
//  Created by André Rohrbeck on 15.09.22.
//

import Foundation


/// An intersection between two ``PathElement``s.
///
/// ``PathElements`` may intersect at one or more points. At the point where they are intersecting
/// they form an angle. This angle corresponds to a change in direction when seeing the Path as going
/// from start to end.
internal struct Intersection {
    /// The point where the two ``PathElements`` are intersecting
    public var point: CGPoint

    /// The first ``PathElement``
    internal var element0: PathElement

    /// The second ``PathElement``
    internal var element1: PathElement

    /// The heading of the first ``PathElement`` in the ``Intersection`` `point`.
    public var angle0: Angle


    /// The heading of the second ``PathElement`` in the ``Intersection`` `point`.
    public var angle1: Angle


    /// The angle describing the change in direction in the ``Intersection``.
    public var directionChange: Double {
        let rawChange = angle1.rad - angle0.rad
        if rawChange > Double.pi {
            return rawChange - 2 * Double.pi
        } else {
            return rawChange
        }

    }
}
