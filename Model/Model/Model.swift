//
//  Model.swift
//  TextCtxTransitionAnimation
//
//  Created by Liwei Zhang on 2016-05-20.
//  Copyright © 2016 Liwei Zhang. All rights reserved.
//

import Foundation

extension CountableRange {
    /// Returns the corresponding positions of start and end indice of
    /// 'rangeInSelf' in 'anotherRange'.
    /// Return 'nil', if endIndex of 'anotherRange' met before the endIndex of
    /// 'rangeInSelf' met.
    @warn_unused_result
    func range<T : protocol<Comparable, _Strideable>>(in anotherCountableRange: CountableRange<T>, for rangeInSelf: CountableRange) -> CountableRange<T>? {
        var anotherLowerBoundForRange: T?
        var anotherUpperBoundForRange: T?
        var anotherIterator = anotherCountableRange.makeIterator()
        var anotherNext = anotherIterator.next()
        for i in CountableClosedRange(lowerBound...upperBound) {
            if anotherCountableRange.startIndex.distance(to: anotherCountableRange.endIndex) > anotherNext?.distance(to: anotherCountableRange.endIndex) {
                break
            }
            if i == rangeInSelf.lowerBound {
                anotherLowerBoundForRange = anotherNext
            }
            if i == rangeInSelf.upperBound {
                anotherUpperBoundForRange = anotherNext
            }
            if let start = anotherLowerBoundForRange, end = anotherUpperBoundForRange {
                return start..<end
            }
            anotherNext = anotherIterator.next()
        }
        return nil
    }
}



protocol Arithmeticable {
    func +(_: Self, _: Self) -> Self
    func -(_: Self, _: Self) -> Self
    func *(_: Self, _: Self) -> Self
    func /(_: Self, _: Self) -> Self
}

extension Int: Arithmeticable {}
extension Int8: Arithmeticable {}
extension Int16: Arithmeticable {}
extension Int32: Arithmeticable {}
extension Int64: Arithmeticable {}
extension UInt: Arithmeticable {}
extension UInt8: Arithmeticable {}
extension UInt16: Arithmeticable {}
extension UInt32: Arithmeticable {}
extension UInt64: Arithmeticable {}

extension Double: Arithmeticable {}
extension Float: Arithmeticable {}


protocol ControlledComparable : Comparable {
    func isEqual(to another: Self) -> Bool
    func isGreater(than another: Self) -> Bool
    func isLess(than another: Self) -> Bool
}

extension IntegerArithmetic {
    @warn_unused_result
    func isEqual(to another: Self) -> Bool {
        return self == another
    }
    @warn_unused_result
    func isGreater(than another: Self) -> Bool {
        return self > another
    }
    @warn_unused_result
    func isLess(than another: Self) -> Bool {
        return self < another
    }
}

extension Int: ControlledComparable {}
extension Int8: ControlledComparable {}
extension Int16: ControlledComparable {}
extension Int32: ControlledComparable {}
extension Int64: ControlledComparable {}
extension UInt: ControlledComparable {}
extension UInt8: ControlledComparable {}
extension UInt16: ControlledComparable {}
extension UInt32: ControlledComparable {}
extension UInt64: ControlledComparable {}

let accuracyPctInDouble: Double = 0.001 * 0.01

extension Double {
    @warn_unused_result
    func isEqual(to another: Double) -> Bool {
        return self - another > -accuracyPctInDouble && self - another < accuracyPctInDouble
    }
    @warn_unused_result
    func isGreater(than another: Double) -> Bool {
        return self - another >= accuracyPctInDouble
    }
    @warn_unused_result
    func isLess(than another: Double) -> Bool {
        return self - another <= -accuracyPctInDouble
    }
}

extension Double: ControlledComparable {}

let accuracyPctInFloat: Float = 0.0001

extension Float {
    @warn_unused_result
    func isEqual(to another: Float) -> Bool {
        return self - another > -accuracyPctInFloat && self - another < accuracyPctInFloat
    }
    @warn_unused_result
    func isGreater(than another: Float) -> Bool {
        return self - another >= accuracyPctInFloat
    }
    @warn_unused_result
    func isLess(than another: Float) -> Bool {
        return self - another <= -accuracyPctInFloat
    }
}

extension Float: ControlledComparable {}

func controlledMin<T : ControlledComparable>(_ x: T, _ y: T) -> T {
    switch x {
        case let d as Double:
            let e = y as! Double
            return (d.isGreater(than: e) ? e : d) as! T
        case let f as Float:
            let g = y as! Float
            return (f.isGreater(than: g) ? g : f) as! T
        default:
            return min(x, y)
    }
}

func controlledMax<T : Comparable>(_ x: T, _ y: T) -> T {
    switch x {
    case let d as Double:
        let e = y as! Double
        return (d.isLess(than: e) ? e : d) as! T
    case let f as Float:
        let g = y as! Float
        return (f.isLess(than: g) ? g : f) as! T
    default:
        return max(x, y)
    }
}


/// To let methods work on both Array and ArraySlice.
extension Collection
where Iterator.Element : ControlledComparable,
      Iterator.Element : Arithmeticable,
      Iterator.Element == SubSequence.Iterator.Element,
      Index == Int,
      Indices == CountableRange<Index> {
    /// For each element in 'self', get the delta from the corresponding one in
    /// 'from' and return as an 'Array'.
    /// Returns 'nil', if any elemnt in either arrays is missing.
    @warn_unused_result
    func deltas
        <T : Collection
             where T.Iterator.Element == Self.Iterator.Element,
                   T.Iterator.Element == T.SubSequence.Iterator.Element,
                   T.Index == Int,
                   T.Indices == CountableRange<Index>
        >(from collection: T, for selectedIndices: Indices? = nil) -> [Iterator.Element]? {
        if count as! Int != collection.count as! Int {
            return nil
        }
        let indicesInSelf = selectedIndices ?? indices
        guard let indicesInFrom = indices.range(in: collection.indices, for: indicesInSelf) else { return nil }
        let selfElementsWithIndices = self[indicesInSelf]
        let fromElementsWithIndices = collection[indicesInFrom]
        var fromIterator = fromElementsWithIndices.makeIterator()
        var deltas: [Iterator.Element] = []
        for selfElement in selfElementsWithIndices {
            if let fromElement = fromIterator.next() {
                deltas.append(selfElement - fromElement)
            }
        }
        return deltas
    }
    
    /// Returns all ranges with continuous non-zero delta in 'Tuple' with
    /// 'Range' as first element and max-delta of this range as second.
    /// Returns 'nil', if any elemnt in either arrays is missing.
    @warn_unused_result
    func nonZeroMaxDeltaIndicesAndDeltas
        <T : Collection
             where T.Iterator.Element == Self.Iterator.Element,
                   T.Iterator.Element == T.SubSequence.Iterator.Element,
                   T.Index == Int,
                   T.Indices == CountableRange<Index>
        >(from collection: T) -> [(CountableRange<Index>, Iterator.Element)]? {
        guard let deltas = deltas(from: collection) else { return nil }
        print("deltas: \(deltas)")
        var results: [(CountableRange<Index>, Iterator.Element)] = []
        if deltas.count == 0 { return results }
        let zero = deltas.first! - deltas.first!
        var headIndex: Index?
        var tailIndex: Index?
        var deltasIterator = deltas.makeIterator()
        var deltaForIndices: Iterator.Element?
        for i in startIndex...endIndex {
            tailIndex = i
            var newPieceReady = false
            let delta = deltasIterator.next()
            if i == endIndex && headIndex != nil { newPieceReady = true }
            if i != endIndex {
                guard let deltaAtPosition = delta else {
                    fatalError("func nonZeroMaxDeltaIndicesAndDeltas came up with invalid deltas.")
                }
                if !deltaAtPosition.isEqual(to: zero) {
                    if let _ = headIndex, deltaForIndicesHere = deltaForIndices {
                        if (deltaForIndicesHere * deltaAtPosition).isLess(than: zero) { newPieceReady = true }
                    }
                    else {
                        headIndex = i
                    }
                    if !newPieceReady {
                        deltaForIndices = (deltaForIndices == nil) ?
                            deltaAtPosition :
                            (deltaAtPosition.isGreater(than: zero) ? controlledMin(deltaForIndices!, deltaAtPosition) : controlledMax(deltaForIndices!, deltaAtPosition))
                    }
                }
                else {
                    newPieceReady = true
                }
            }
            if newPieceReady {
                if let start = headIndex, end = tailIndex, deltaHere = deltaForIndices {
                    results.append((start..<end, deltaHere))
                }
                headIndex = nil
                tailIndex = nil
                deltaForIndices = nil
                if delta != nil && !delta!.isEqual(to: zero) {
                    headIndex = i
                    deltaForIndices = delta
                }
            }
        }
        return results
    }
    /// Returns a new 'Array' with elements in 'range' modified by 'delta'.
    /// Returns 'nil', if 'range' is out of bounds.
    @warn_unused_result
    func apply(delta: Iterator.Element, to selectedIndices: CountableRange<Index>) -> [Iterator.Element]? {
        if startIndex.distance(to: selectedIndices.startIndex) < 0 || endIndex.distance(to: selectedIndices.endIndex) > 0 { return nil }
        var deltas: [Iterator.Element] = []
        let zero = delta - delta
        deltas.append(contentsOf: repeatElement(zero, count: (startIndex..<selectedIndices.startIndex).count))
        deltas.append(contentsOf: repeatElement(delta, count: ((selectedIndices.startIndex..<selectedIndices.endIndex).count)))
        deltas.append(contentsOf: repeatElement(zero, count: (selectedIndices.endIndex..<endIndex).count))
        var newNumbers: [Iterator.Element] = []
        var deltasIterator = deltas.makeIterator()
        for number in self {
            newNumbers.append(number + deltasIterator.next()!)
        }
        return newNumbers
    }
    
}
extension Array where Element : ControlledComparable, Element: Arithmeticable {
    /// Returns all deltas, ranges applied and new arrays generated to reach
    /// self.
    /// Returns 'nil', if there is no corresponding element in either array or
    /// 'deltaPicker' fails to pick.
    @warn_unused_result
    func deltasAndIndicesWithNewArrays(from array: [Element], deltaPicker: @noescape([(CountableRange<Int>, Element)]) -> (CountableRange<Int>, Element)?) -> (deltas: [Iterator.Element], ranges: [CountableRange<Int>], newArrays: [[Element]])? {
        if count != array.count { return nil }
        var deltas: [Iterator.Element] = []
        var allIndices: [CountableRange<Int>] = []
        var newArrays: [[Element]] = []
        var newCollection = array
        var numberOfOptions = nonZeroMaxDeltaIndicesAndDeltas(from: array)?.count ?? 0
        while numberOfOptions > 0 {
            if let options = nonZeroMaxDeltaIndicesAndDeltas(from: newCollection) {
                print("OPTIONS: \(options)")
                numberOfOptions = options.count
                if numberOfOptions > 0 {
                    guard let pick = deltaPicker(options)
                        else { return nil }
                    deltas.append(pick.1)
                    allIndices.append(pick.0)
                    newCollection = (newArrays.last ?? array).apply(delta: pick.1, to: pick.0)!
                    newArrays.append(newCollection)
                }
            }
            else {
                return nil
            }
        }
        return (deltas, allIndices, newArrays)
    }
}
