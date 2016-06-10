//
//  Model.swift
//  TextCtxTransitionAnimation
//
//  Created by Liwei Zhang on 2016-05-20.
//  Copyright © 2016 Liwei Zhang. All rights reserved.
//

import Foundation


/// Problem to solve:
/// Given a list of numbers and new values of each number. Each time, only one
/// non zero delta can be applied to a non empty subset of continuous members of 
/// the list. The delta needs to minimize the gap between current value and new 
/// value for each number applied, while not creating new gap for any member.

/// Solution:
/// Data Structure:
/// To have easier way to find corresponding number pair, group the initial and
/// target together and form a new list. To know the whole transform clearly,
/// record all changes (including zeros) for each step. Append each step's 
/// change after the initial. To clearly identify the target and each step's 
/// number, a dictionary with target as key and an array of number as value is a
/// good structure to group them. Two lists of numbers transform to be a list of
/// dictionaries.
/// Calculation:
/// Find out all continuous non-zero-delta-to-reach-target ranges for current 
/// numbers. Get max delta necessary for each number in the range for each
/// range. Follow a rule provided to pick the range to operate on. Execute and
/// loop the process till no non-zero-delta-to-reach-target range can be found.

/// List of targets, not going to change.
/// List of range and its delta, appended in each step.
/// List of updated numbers, new list after each step.

/// Base data structure is a list of targets. Each time a list of updated values
/// is applied to it to get answers.

/// max-deltas: means, in a continuous range, the max delta that all its
/// members can be added in the progress of reaching each's target, but not
/// over-reaching for any member.

extension Range {
    /// Returns the corresponding positions of start and end indice in
    /// 'anotherRange' for 'rangeInSelf'.
    /// Return 'nil' if endIndex of 'anotherRange' met before the endIndex of
    /// 'rangeInSelf' met.
    @warn_unused_result
    func range<T : ForwardIndexType>(in anotherRange: Range<T>, for rangeInSelf: Range) -> Range<T>? {
        var anotherStartIndexForRange = anotherRange.startIndex
        var anotherEndIndexForRange = anotherRange.endIndex
        var selfSuccessor = startIndex
        var anotherSuccessor = anotherRange.startIndex
        for _ in self {
            if anotherRange.endIndex < anotherSuccessor {
                return nil
            }
            if selfSuccessor == rangeInSelf.startIndex {
                anotherStartIndexForRange = anotherSuccessor
            }
            if selfSuccessor == rangeInSelf.endIndex {
                anotherEndIndexForRange = anotherSuccessor
            }
            selfSuccessor = selfSuccessor.successor()
            anotherSuccessor = anotherSuccessor.successor()
        }
    }
}

extension CollectionType where Generator.Element : Numberable {
    /// Returns the shortest 'Array' of delta in Generator.Element.
    @warn_unused_result
    func deltas<T : CollectionType where T.Generator.Element == Self.Generator.Element>(from collection: T, for range: Range<Index>) -> [Generator.Element] {
        var selfGen = generate()
        var anotherGen = collection.generate()
        var deltas: [Generator.Element] = []
        for i in range {
            guard let selfElement = selfGen.next() else { break }
            guard let anotherElement = anotherGen.next() else { break }
            deltas.append(selfElement - anotherElement)
        }
        return deltas
    }
    /// Returns the max-delta value 'Self.Generator.Element.Number' valid for
    /// all members in the 'range'
    /// Returns 'nil', if no member in 'range'.
    @warn_unused_result
    func maxDelta(for range: Range<Index>) -> Generator.Element.Number? {
        return deltas(for: range).minElement()
    }
}

typealias currentAndTargetNumbers = [[Numberable]]

/// Provides a Numberable type for adopters.
protocol HasNumber {
    associatedtype number: Numberable
}

/// Provides a ForwardIndexType type for adopters.
protocol IndexOfRange {
    associatedtype rangeElement : ForwardIndexType
}

protocol DeltasFoundable : HasNumber, IndexOfRange {
    @warn_unused_result func deltas(for range: Range<rangeElement>) -> [number]
    /// Returns the max delta that everyone in a range can be applied to.
    @warn_unused_result func maxDelta(for range: Range<rangeElement>) -> number?
    @warn_unused_result func nonZeroMaxDeltaRangesAndDeltas() -> [Range<rangeElement>: number]
}

/// Makes Range conform to Hashable.
extension Range : Hashable {
    public var hashValue: Int {
        return String(startIndex).hashValue ^ String(endIndex).hashValue
    }
}

protocol NewNumbersTransformable : HasNumber, IndexOfRange {
    @warn_unused_result func updatedBy(delta: number, for range: Range<rangeElement>) -> Self
    /// Returns range associated with delta for each step in the execution
    /// order. The deltaPicker provides how each delta is selected, given all
    /// possible deltas and their corresponding ranges for a step.
    @warn_unused_result func deltasWithRangesToAllNewNumbers(deltaPicker: (rangesAndDeltasForCurrentStep: [Range<rangeElement>: number]) -> (Range<rangeElement>, number)) -> [Range<rangeElement>: number]
}

/// Extracts some behaviors of a Dictionary so that a non-concrete Dictionary
/// can be used.
protocol NumberableKeyNumberableArrayValueDictionary : CollectionType, DictionaryLiteralConvertible {
    associatedtype Number : Numberable
    associatedtype Element = (Number, [Number])
    var keys: LazyMapCollection<[Number : Number], Number> { get }
    subscript (key: Number) -> [Number]? { get set }
}

/// Numberable list.
extension CollectionType where Generator.Element : Numberable, SubSequence.Generator.Element == Generator.Element {
    @warn_unused_result
    func updated(by delta: Generator.Element, for range: Range<Index>) -> [Generator.Element] {
        let head = self[startIndex..<range.startIndex]
        let tail = self[range.endIndex..<endIndex]
        let toUpdate = self[range]
        let updated = toUpdate.map { $0 + delta }
        return Array(head) + Array(updated) + Array(tail)
    }
}

/// Numberable dictionary list
extension CollectionType where Generator.Element : NumberableKeyNumberableArrayValueDictionary, SubSequence.Generator.Element == Generator.Element {
    /// max-deltas: means, in a continuous range, the max delta that all its
    /// members can be added in the progress of reaching each's target, but not
    /// over-reaching for any member.
    
    /// Returns an 'Array' of 'Generator.Element.Number' to list all 
    /// non-zero-max-deltas in the 'range', while the number of elements of the 
    /// 'Array' keeps minimum.
    @warn_unused_result
    func deltas(for range: Range<Index>) -> [Generator.Element.Number] {
        let membersInRange = self[range]
        return membersInRange.map { (dic) -> Generator.Element.Number in
            guard let key = dic.keys.first else {
                fatalError("No Key in Dictionary<NumberableKeyNumberableArrayValueDictionary, NumberableKeyNumberableArrayValueDictionary>")
            }
            guard let latest = dic[key]?.last else {
                fatalError("No member in Array Value of Dictionary<NumberableKeyNumberableArrayValueDictionary, NumberableKeyNumberableArrayValueDictionary>")
            }
            return key - latest
        }
    }
    
    /// Returns the max-delta value 'Self.Generator.Element.Number' valid for
    /// all members in the 'range'
    /// Returns 'nil', if no member in 'range'.
    @warn_unused_result
    func maxDelta(for range: Range<Index>) -> Generator.Element.Number? {
        return deltas(for: range).minElement()
    }
    /// Returns all ranges with continuous non-zero delta in Dictionary with 
    /// Range as Key and max-delta of this range as Value.
    @warn_unused_result
    func nonZeroMaxDeltaRangesAndDeltas() -> [Range<Index>: Generator.Element.Number] {
        let ds = deltas(for: startIndex..<endIndex)
        var results: [Range<Index>: Generator.Element.Number] = [:]
        var startI: Index? = nil
        var endI: Index? = nil
        var deltasGen = ds.generate()
        var deltaNow: Generator.Element.Number? = nil
        for i in startIndex..<endIndex {
            guard let delta = deltasGen.next() else {
                fatalError("func nonZeroMaxDeltaRangesAndDeltas came up with invalid deltas.")
            }
            if delta != delta.zero {
                if startI == nil {
                    startI = i
                }
                endI = i
                deltaNow = (deltaNow == nil) ? delta : min(deltaNow!, delta)
            }
            else {
                if let end = endI {
                    results[startI!..<end] = deltaNow
                }
                startI = nil
                endI = nil
                deltaNow = nil
            }
        }
        if let start = startI, end = endI, delta = deltaNow {
            results[start..<end] = delta
        }
        return results
    }
    /// Returns a new 'Array' of 'Generator.Element'. Each of its element has 
    /// key-value pairs, where value is an array. The existing value of each
    /// pair is appended with a new number. Numbers fall in 'range' are added by
    /// 'delta' based on previous last numbers. Numbers out of 'range' provided
    /// remain the same.
    @warn_unused_result
    func updated(by delta: Generator.Element.Number, for range: Range<Index>) -> [Generator.Element] {
        var deltas: [Generator.Element.Number] = []
        deltas.appendContentsOf(Repeat(count: ((startIndex..<range.startIndex).count as! Int), repeatedValue: delta.zero))
        deltas.appendContentsOf(Repeat(count: ((range.startIndex..<range.endIndex).count as! Int), repeatedValue: delta))
        deltas.appendContentsOf(Repeat(count: ((range.endIndex..<endIndex).count as! Int), repeatedValue: delta.zero))
        return map { (dic) -> Generator.Element in
            guard let key = dic.keys.first else {
                fatalError("Empty Dictionary.")
            }
            var d = dic[key]!
            d.append(delta)
            var newDic = dic
            newDic[key] = d
            return newDic
        }
    }
    
    /// Returns an 'Array' of 'Generator.Element' and ranges with their 
    /// corresponding deltas for all the steps to reach targets so far, if new 
    /// ranges with delta found.
    /// Returns nil, if no new ones found.
    @warn_unused_result
    func deltaWithRangeToNewNumber(
        deltasAndRanges: [(Range<Index>, Generator.Element.Number)],
        deltaPicker: (rangesAndDeltasForCurrentStep: [Range<Index>: Generator.Element.Number]) -> (Range<Index>, Generator.Element.Number)?
        ) -> ([Generator.Element], [(Range<Index>, Generator.Element.Number)])? {
        let options: [Range<Index>: Generator.Element.Number] = nonZeroMaxDeltaRangesAndDeltas()
        if options.count > 0 {
            guard let picked = deltaPicker(rangesAndDeltasForCurrentStep: options) else {
                fatalError("deltaPicker did not pick anyone.")
            }
            var newDeltasAndRanges = deltasAndRanges
            newDeltasAndRanges.append(picked)
            let newSelf = updated(by: picked.1, for: picked.0)
            return (newSelf, newDeltasAndRanges)
        }
        return nil
    }
    
}


