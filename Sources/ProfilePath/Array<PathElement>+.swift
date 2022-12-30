//
//  Array<PathElement>+.swift
//  
//
//  Created by André Rohrbeck on 01.11.22.
//

import Foundation



extension Array where Element == PathElement {
    internal func reversedCompletely() -> [PathElement] {
        self.reversed().map {
            $0.reversed
        }
    }
}


extension Array where Element == PathElement {

    func appendingFirstElement(_ element: PathElementDescription) -> [PathElement] {
        if let line = element as? Line {
            return self.appending(first: line)
        } else if let arc = element as? Arc {
            do {
                return try self.appending(arc)
            } catch {
                return []
            }
        } else {
            return []
        }
    }



// MARK: - Appending Lines
    internal func appending(first line: Line) -> [PathElement] {
        guard let start = line.start, let end = line.end else {
            return []
        }
        var result = self
        result.append(LineElement(start: start, end: end))
        return result
    }

    internal func appending(_ line: Line,
                            with connectingElement: ConnectingElementDescription? = nil) throws -> [PathElement] {
        var result = self
        if let start = line.start,
           let end = line.end {
            if last is LineElement {
                let newLine = LineElement(start: start, end: end)
                result = result.appending(intersectingLine: newLine,
                                          connectingWith: connectingElement)
            } else if last is ArcElement {
                let newLine = LineElement(start: start, end: end)
                result = result.appending(intersectingLine: newLine,
                                          connectingWith: connectingElement)
            } else if let currentPoint = result.last?.endPoint {
                result.append(LineElement(start: currentPoint, end: end))
            } else {
                result.append(LineElement(start: start, end: end))
            }
        } else if let end = line.end, let heading = line.heading {
            let newLine = LineElement(heading: heading, length: 1000, end: end)
            result = result.appending(intersectingLine: newLine, connectingWith: connectingElement)
        } else if let end = line.end, let curPoint = result.last?.endPoint {
            let newLine = LineElement(start: curPoint, end: end)
            if result.last is LineElement {
                result = result.appending(intersectingLine: newLine,
                                          connectingWith: connectingElement)
            } else {
                result.append(LineElement(start: curPoint, end: end))
            }
        } else if line.start == nil, line.end == nil, line.heading == nil,
                  let curPoint = result.last?.endPoint,
                  let curHeading = result.last?.endHeading {
            let newLine = LineElement(start: curPoint, heading: curHeading, length: 1000) // 1000 as arbitrary length
            result.append(newLine)
        } else if let start = line.start,
                  let heading = line.heading {
            let newLine = LineElement(start: start, heading: heading, length: 1000)
            result = result.appending(intersectingLine: newLine, connectingWith: connectingElement)
        } else if let curPoint = result.last?.endPoint,
                  let heading = line.heading {
            let newLine = LineElement(start: curPoint, heading: heading, length: 1000)
            result.append(newLine)
        } else {
            throw ProfilePathError.elementNotAppended
        }
        return result
    }


    internal func appending(intersectingLine newLine: LineElement,
                            connectingWith: ConnectingElementDescription? = nil) -> [PathElement] {
        if let lastLine = self.last as? LineElement {
        if let intersection = try? GeometricCalculations.intersection(lastLine, newLine) {
                if let fillet = connectingWith as? Fillet {
                    if let filletArc = try? GeometricCalculations.fillet(lastLine, newLine, radius: fillet.radius) {
                        var result: [PathElement] = dropLast()
                        result.append(LineElement(start: lastLine.start, end: filletArc.start))
                        result.append(ArcElement(center: filletArc.center,
                                                 radius: filletArc.radius,
                                                 start: filletArc.start,
                                                 end: filletArc.end,
                                                 negativeDirection: filletArc.negativeDirection))
                        result.append(LineElement(start: filletArc.end,
                                                  end: newLine.end,
                                                  isEndValidEndPoint: newLine.isEndValidEndPoint))
                        return result
                    }
                } else {
                    var result: [PathElement] = self.dropLast()
                    result.append(LineElement(start: lastLine.start, end: intersection.point))
                    result.append(LineElement(start: intersection.point,
                                              end: newLine.end,
                                              isEndValidEndPoint: newLine.isEndValidEndPoint))
                    return result
                }
            }
        } else if let lastArc = self.last as? ArcElement {
            if let fillet = connectingWith as? Fillet {
                if let filletArc = try? GeometricCalculations.fillet(lastArc, newLine, radius: fillet.radius) {
                    var result: [PathElement] = dropLast()
                    result.append(ArcElement(center: lastArc.center,
                                             radius: lastArc.radius,
                                             start: lastArc.start,
                                             end: filletArc.start,
                                             negativeDirection: lastArc.negativeDirection))
                    result.append(ArcElement(center: filletArc.center,
                                             radius: filletArc.radius,
                                             start: filletArc.start,
                                             end: filletArc.end,
                                             negativeDirection: filletArc.negativeDirection))
                    result.append(LineElement(start: filletArc.end,
                                              end: newLine.end,
                                              isEndValidEndPoint: newLine.isEndValidEndPoint))
                    return result
                }
            }
        }

        return self
    }


// MARK: - Appending Arcs
    func appending(_ arc: Arc, with connectingElement: ConnectingElementDescription? = nil) throws -> [PathElement] {
        guard let last else {
            return try appendAsFirstElement(arc)
        }

        var result = self
        if let toX = arc.toX,
                  let curPoint = last.endPoint {
            let center = GeometricCalculations.arcCenter(tangentiallyAppendingTo: curPoint,
                                                         heading: last.endHeading,
                                                         radius: arc.radius,
                                                         negativeDirection: arc.negativeDirection)
            let end = Arc.endPoint(center: center,
                                   radius: arc.radius,
                                   start: curPoint,
                                   toX: toX,
                                   negativeDirection: arc.negativeDirection)
            result.append(ArcElement(center: center,
                                     radius: arc.radius,
                                     start: curPoint,
                                     end: end,
                                     negativeDirection: arc.negativeDirection))
        } else if let endAngle = arc.endAngle,
                  let curPoint = last.endPoint {
            let center = GeometricCalculations.arcCenter(tangentiallyAppendingTo: curPoint,
                                                         heading: last.endHeading,
                                                         radius: arc.radius,
                                                         negativeDirection: arc.negativeDirection)
            let startAngle = arc.negativeDirection
            ? last.endHeading + Angle(degrees: 90)
            : last.endHeading - Angle(degrees: 90)
            result.append(ArcElement(center: center,
                                     radius: arc.radius,
                                     startAngle: startAngle,
                                     endAngle: endAngle,
                                     negativeDirection: arc.negativeDirection))
        } else if let last = last as? LineElement {
            result = try result.append(arc, toLine: last, connectingElement: connectingElement)
        } else if let last = last as? ArcElement {
            result = try result.append(arc, toArc: last, connectingElement: connectingElement)
        } else {
            throw ProfilePathError.elementNotAppended
        }
        return result
    }



    func appendAsFirstElement(_ arc: Arc) throws -> [PathElement] {
        var result = self
        if let center = arc.center,
           let start = arc.start,
           let toX = arc.toX {
            let end = Arc.endPoint(center: center,
                                   radius: arc.radius,
                                   start: start,
                                   toX: toX,
                                   negativeDirection: arc.negativeDirection)
            result.append(ArcElement(center: center,
                                     radius: arc.radius,
                                     start: start,
                                     end: end,
                                     negativeDirection: arc.negativeDirection))
        } else if let center = arc.center, last == nil {
            result.append(ArcElement(center: center,
                                     radius: arc.radius,
                                     startAngle: Angle(degrees: 0),
                                     endAngle: Angle(degrees: 0),
                                     negativeDirection: arc.negativeDirection))
        } else {
            throw ProfilePathError.elementNotAppended
        }
        return result
    }



    func append(_ arc: Arc,
                toLine line: LineElement,
                connectingElement: ConnectingElementDescription?) throws -> [PathElement] {
        if let centerY = arc.centerY,
           connectingElement == nil {
            var result = self
            let parallelLine: LineElement
            if arc.negativeDirection {
                parallelLine = GeometricCalculations.parallel(to: line, distance: arc.radius)
            } else {
                parallelLine = GeometricCalculations.parallel(to: line, distance: -arc.radius)
            }
            let horizontalAtY = LineElement(start: CGPoint(x: 0.0, y: centerY), end: CGPoint(x: 10.0, y: centerY))
            if let center = try? GeometricCalculations.intersection(parallelLine, horizontalAtY) {
                let perpendicularThroughCenter = GeometricCalculations.perpendicular(to: line, through: center.point)
                if let start = try? GeometricCalculations.intersection(line, perpendicularThroughCenter) {
                    result = result.dropLast()
                    result.append(LineElement(start: line.start, end: start.point))
                    result.append(ArcElement(center: center.point,
                                             radius: arc.radius,
                                             start: start.point,
                                             end: start.point,
                                             negativeDirection: arc.negativeDirection))
                }
            }
            return result
        } else if let center = arc.center, let connectingElement {
            var result = self
            let startAngle = arc.negativeDirection ? Angle(degrees: 1) : Angle(degrees: 0)
            let endAngle = arc.negativeDirection ? Angle(degrees: 0) : Angle(degrees: 1)
            let testArc = ArcElement(center: center,
                                     radius: arc.radius,
                                     startAngle: startAngle,
                                     endAngle: endAngle,
                                     negativeDirection: arc.negativeDirection)
            let connection = connection(line, connectingElement, testArc)
            if !connection.isEmpty {
                result.removeLast()
                result.append(contentsOf: connection)
                return result
            } else {
                throw ProfilePathError.elementNotAppended
            }
        } else {
            throw ProfilePathError.elementNotAppended
        }
    }



    func append(_ arc: Arc,
                toArc lastArc: ArcElement,
                connectingElement: ConnectingElementDescription?) throws -> [PathElement] {
        if let centerY = arc.centerY,
           connectingElement == nil {
            var result = self
            let parallelArc = ArcElement(center: lastArc.center,
                                         radius: lastArc.radius - arc.radius,
                                         startAngle: lastArc.startAngle,
                                         endAngle: lastArc.endAngle,
                                         negativeDirection: lastArc.negativeDirection)
            let horizontalAtY = LineElement(start: CGPoint(x: 0.0, y: centerY), end: CGPoint(x: 10.0, y: centerY))
            do {
                let potentialNewArcCenters = try GeometricCalculations.intersections(parallelArc, horizontalAtY)
                    .sorted {
                        let arcLength0 = lastArc.angularLength(to: $0.point)
                        let arcLength1 = lastArc.angularLength(to: $1.point)
                        return abs(arcLength0.degrees) < abs(arcLength1.degrees)
                    }
                if let center = potentialNewArcCenters.first?.point {
                    let newIntersectionAngle = GeometricCalculations.angle(of: center, inRespectTo: lastArc.center)
                    result = result.dropLast()
                    result.append(ArcElement(center: lastArc.center,
                                             radius: lastArc.radius,
                                             startAngle: lastArc.startAngle,
                                             endAngle: newIntersectionAngle,
                                             negativeDirection: lastArc.negativeDirection))
                    result.append(ArcElement(center: center,
                                             radius: arc.radius,
                                             startAngle: newIntersectionAngle,
                                             endAngle: newIntersectionAngle,
                                             negativeDirection: arc.negativeDirection))
                } else {
                    throw ProfilePathError.elementNotAppended
                }
                return result
            } catch {
                throw ProfilePathError.elementNotAppended
            }
        }
        throw ProfilePathError.elementNotAppended
    }


    func appending(_ path: [PathElement],
                   with connectingElement: ConnectingElementDescription?) -> [PathElement] {
        if let connectingElement {
            if let first = self.last,
               let last = path.first {
                let connectingElements: [PathElement]
                connectingElements = connection(first, connectingElement, last)
                return Array(self.dropLast()) + connectingElements + Array(path.dropFirst())
            }
        }
        // TODO: This should perhaps calculate the intersection and reduce the length of another element accordingly
        let result: [PathElement] = self + path
        return result
    }


    internal func connection(_ firstElement: PathElement,
                             _ connectingElement: ConnectingElementDescription,
                             _ secondElement: PathElement) -> [PathElement] {
        if let line = firstElement as? LineElement,
           let arc = secondElement as? ArcElement,
           let fillet = connectingElement as? Fillet {
            return connection(arc: arc.reversed, fillet: fillet, line: line.reversed).reversedCompletely()
        } else if let arc = firstElement as? ArcElement,
                  let line = secondElement as? LineElement,
                  let fillet = connectingElement as? Fillet {
            return connection(arc: arc, fillet: fillet, line: line)
        } else if let line0 = firstElement as? LineElement,
                  let line1 = secondElement as? LineElement,
                  let fillet = connectingElement as? Fillet {
            return connection(line0: line0, fillet: fillet, line1: line1)
        } else {
            return [firstElement, secondElement]
        }
    }


    private func connection(arc: ArcElement, fillet: Fillet, line: LineElement) -> [PathElement] {
        if let filletArc = try? GeometricCalculations.fillet(arc, line, radius: fillet.radius) {
            let modifiedArc = ArcElement(center: arc.center,
                                         radius: arc.radius,
                                         start: arc.start,
                                         end: filletArc.start,
                                         negativeDirection: filletArc.negativeDirection)
            let modifiedLine = LineElement(start: filletArc.end, end: line.end)
            return [modifiedArc, filletArc, modifiedLine]
        } else {
            return [arc, line]
        }
    }


    private func connection(line0: LineElement, fillet: Fillet, line1: LineElement) -> [PathElement] {
        if let filletArc = try? GeometricCalculations.fillet(line0, line1, radius: fillet.radius) {
            let modifiedLine0 = LineElement(start: line0.start, end: filletArc.start)
            let modifiedLine1 = LineElement(start: filletArc.end, end: line1.end)
            return [modifiedLine0, filletArc, modifiedLine1]
        } else {
            return [line0, line1]
        }
    }
}
