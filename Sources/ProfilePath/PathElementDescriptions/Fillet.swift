//
//  Fillet.swift
//  
//
//  Created by André Rohrbeck on 15.09.22.
//

import Foundation

/// Describes a ``PathElement`` connecting two intersecting lines with a radius.
public struct Fillet: ConnectingElementDescription {
    // The radius of the fillet.
    public var radius: CGFloat

    /// Creates a ``Fillet`` with a given `radius`.
    ///
    /// - Parameter radius: The radius of the fillet.
    public init(radius: CGFloat) {
        self.radius = radius
    }


    public var isCompletelyDefined: Bool {
        false
    }


    public var reversed: PathElementDescription {
        self
    }
}
