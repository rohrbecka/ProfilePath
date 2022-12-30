//
//  Angle.swift
//  
//
//  Created by André Rohrbeck on 23.09.22.
//

import Foundation

/// A value representing a geometric angle.
///
/// If the ``Angle`` is used as an absolute direction, an angle of 0 is representing the direction
/// of the x-axis. The y-axis is at an angle of 90° or π/2.
///
/// The raw angle value is stored as non-normalized radians value.
/// The value is normalised, whenever it is requested.
///
public struct Angle: Equatable {
    /// The raw value of the ``Angle`` in degrees, which is not normalized.
    private var rawValue: CGFloat



    /// The angle in radians. Going from 0 (representing the x-axis) to 2π (excluded).
    public var rad: CGFloat {
        (rawValue / 180.0 * Double.pi).normalised(0..<Double.pi*2.0)
    }



    /// The ``Angle`` in degrees going from 0° to 360° (excluded).
    public var degrees: CGFloat {
        rawValue.normalised(0..<360.0)
    }



    /// Creates a new ``Angle`` based on a radians value.
    ///
    /// - Parameter radValue: The angle value in radians (normalised).
    public init(radians radValue: CGFloat) {
        self.rawValue = radValue / Double.pi * 180.0
    }


    /// Creates a new ``Angle`` based on an x/y ratio.
    // swiftlint:disable identifier_name
    public init(dx: CGFloat, dy: CGFloat) {
        guard dx != 0 || dy != 0 else {
            fatalError("Tried to create an angle based on a ratio of x = 0 and y = 0.")
        }
        if dx == 0 {
            self.rawValue = dy > 0 ? 90.0 : -90.0
        } else if dy == 0 {
            self.rawValue = dx > 0 ? 0.0 : 180.0
        } else if dx > 0 {
            self.rawValue = atan(dy / dx) * 180.0 / Double.pi
        } else { // dx < 0
            self.rawValue = atan(dy / dx) * 180.0 / Double.pi + 180.0
        }
    }
    // swiftlint:enable identifier_name



    /// Creates a new ``Angle`` based on a value in degree.
    ///
    /// - Parameter degValue: The angle value in degrees (normalised).
    public init(degrees degValue: CGFloat) {
        self.rawValue = degValue
    }



    public static func == (lhs: Angle, rhs: Angle) -> Bool {
        lhs.rad == rhs.rad
    }



    public static func + (lhs: Angle, rhs: Angle) -> Angle {
        Angle(degrees: lhs.degrees + rhs.degrees)
    }



    public static func - (lhs: Angle, rhs: Angle) -> Angle {
        Angle(degrees: lhs.degrees - rhs.degrees)
    }
}



extension CGFloat {
    /// Returns the ``Double`` value normalised to a certain range.
    func normalised(_ range: Range<Double>) -> Double {
        var value = self
        let delta = range.upperBound - range.lowerBound
        while value < range.lowerBound {
            value += delta
        }
        while value >= range.upperBound {
            value -= delta
        }
        return value
    }
}
