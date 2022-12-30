//
//  ProfilePathElement.swift
//  
//
//  Created by André Rohrbeck on 15.09.22.
//

import Foundation


/// An element of a ``Path``.
public protocol PathElement {
    /// The startpoint of the ``PathElement`
    var startPoint: CGPoint { get }


    var startHeading: Angle { get }

    /// The endpoint of the path element.
    ///
    /// Some Path Elements have an open end (as RayElements). These need another ``PathElement`` to define their
    /// end. This is only temporarily as the end point gets defined during parsing of the ``Path``,
    /// but is necessary. Imagine two lines. The first line has a start and a heading. The second one has
    /// an end and a heading. It would be not possible to parse this Path without temporarily allowing an
    /// "open end". Therefore this property must be optional.
    var endPoint: CGPoint? { get }

    /// The direction of the ned of the path element (in x-direction is 0, in y is π/2, negative
    /// x is -π and negative y is -3/2·π.
    var endHeading: Angle { get }

    /// Returns this ``PathElement``assuming, that the Path is running in the opposite direction.
    var reversed: Self { get }
}
