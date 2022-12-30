//
//  ProfilePath.swift
//  
//
//  Created by André Rohrbeck on 27.08.22.
//

import Foundation

/// The description of a profile by path elements
public struct Path {
    public var elements: [PathElement]


    public init(@PathBuilder _ content: () -> [PathElement]) {
        self.elements = content()
    }


    public func profile(resolution: Double) -> [CGPoint] {
        var result = [CGPoint]()
        for element in elements {
            if let line = element as? LineElement {
                result += Sampler.straightLine(from: line.start, to: line.end, resolution: resolution)
            } else if let arc = element as? ArcElement {
                result += Sampler.arc(from: arc.start,
                                      to: arc.end,
                                      center: arc.center,
                                      radius: arc.radius,
                                      negativeDirection: arc.negativeDirection,
                                      resolution: resolution)
            }
        }
        return result
    }
}



@resultBuilder
public struct PathBuilder {

    public static func buildBlock() -> [PathElement] {
        []
    }


    public static func buildBlock(_ elements: PathElementDescription...) -> [PathElement] {
        buildBlock(elements)
    }



    public static func buildBlock(_ elements: [PathElementDescription]) -> [PathElement] {
        var stackOfUnusedElements = [PathElementDescription]()
        var result = [PathElement]()
        var connectingElement: ConnectingElementDescription?
        for element in elements {
            if result.isEmpty {
                result = result.appendingFirstElement(element)
            } else if !stackOfUnusedElements.isEmpty {
                stackOfUnusedElements.append(element)
                if element.isCompletelyDefined {
                    let pathElements = buildBlock(stackOfUnusedElements.reversedCompletely()).reversedCompletely()
                    result = result.appending(pathElements, with: connectingElement)
                    stackOfUnusedElements = [PathElementDescription]()
                    connectingElement = nil
                }
            } else if let line = element as? Line {
                do {
                    result = try result.appending(line, with: connectingElement)
                    connectingElement = nil
                } catch {
                    stackOfUnusedElements.append(element)
                }
            } else if let arc = element as? Arc {
                do {
                    result = try result.appending(arc, with: connectingElement)
                    connectingElement = nil
                } catch {
                    // take the element and store it in the stack of unused element descriptions
                    stackOfUnusedElements.append(element)
                }
            } else if let connection = element as? ConnectingElementDescription {
                connectingElement = connection
            }
        }
        return result
    }
}



extension Array where Element == PathElementDescription {
    fileprivate func reversedCompletely() -> [PathElementDescription] {
        self.reversed().map {
            $0.reversed
        }
    }
}



enum ProfilePathError: Error {
    case elementNotAppended
}
