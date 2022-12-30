//
//  PathElementDescription.swift
//  
//
//  Created by André Rohrbeck on 15.09.22.
//

import Foundation

/// The basic building block to build a ``Path``.
public protocol PathElementDescription {

    /// Returns `true` if the element is completely defined and can be drawn.
    var isCompletelyDefined: Bool { get }

    /// Returns this ``PathElementDescription`` assuming, that the Path is running in the opposite direction.
    var reversed: PathElementDescription { get }
}
