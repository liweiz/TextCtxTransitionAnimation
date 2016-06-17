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
    /// Returns the corresponding positions of start and end indice of 
    /// 'rangeInSelf' in 'anotherRange'.
    /// Return 'nil' if endIndex of 'anotherRange' met before the endIndex of
    /// 'rangeInSelf' met.
    @warn_unused_result
    func range<T : Comparable>(in anotherRange: Range<T>, for rangeInSelf: Range) -> Range<T>? {
        var anotherStartIndexForRange: T?
        var anotherEndIndexForRange: T?
        var anotherSuccessor = anotherRange.lowerBound
        for i in lowerBound..<upperBound {
            if anotherRange.distance(from: anotherRange.endIndex, to: anotherRange.endIndex) > <#T##Collection corresponding to `anotherSuccessor`##Collection#>.distance(from: anotherSuccessor, to: anotherRange.endIndex) {
                break
            }
            if i == rangeInSelf.startIndex {
                anotherStartIndexForRange = anotherSuccessor
            }
            if i == rangeInSelf.endIndex {
                anotherEndIndexForRange = anotherSuccessor
            }
            if let start = anotherStartIndexForRange, end = anotherEndIndexForRange {
                return start..<end
            }
            anotherSuccessor = <#T##Collection corresponding to `anotherSuccessor`##Collection#>.index(after: anotherSuccessor)
        }
        return nil
    }
}

extension Collection where Iterator.Element : Numberable, Iterator.Element == SubSequence.Iterator.Element {
    /// For each element in 'self', get the delta from the corresponding one in
    /// 'from' and return as an 'Array'.
    /// Returns 'nil', if any elemnt in either arrays is missing.
    @warn_unused_result
    func deltas<T : Collection where T.Iterator.Element == Self.Iterator.Element, T.Iterator.Element == T.SubSequence.Iterator.Element>(from collection: T, for range: Range<Index>? = nil) -> [Iterator.Element]? {
        let selfRange = range ?? indices
        guard let rangeInFrom = (indices).range(in: collection.indices, for: selfRange) else { return nil }
        let selfElementsInRange = self[selfRange]
        let fromElementsInRange = collection[rangeInFrom]
        var fromGen = fromElementsInRange.makeIterator()
        var deltas: [Iterator.Element] = []
        for selfElement in selfElementsInRange {
            if let fromElement = fromGen.next() {
                deltas.append(selfElement - fromElement)
            }
        }
        return deltas
    }
    
    /// Returns all ranges with continuous non-zero delta in 'Tuple' with
    /// 'Range' as first element and max-delta of this range as second.
    /// Returns 'nil', if any elemnt in either arrays is missing.
    @warn_unused_result
    func nonZeroMaxDeltaRangesAndDeltas<T : Collection where T.Iterator.Element == Self.Iterator.Element, T.Iterator.Element == T.SubSequence.Iterator.Element>(from collection: T) -> [(Range<Index>, Iterator.Element)]? {
        guard let deltas = deltas(from: collection) else { return nil }
        var results: [(Range<Index>, Iterator.Element)] = []
        var headIndex: Index?
        var tailIndex: Index?
        var deltasGen = deltas.makeIterator()
        var deltaForRange: Iterator.Element?
        for i in indices {
            guard let deltaAtPosition = deltasGen.next() else {
                fatalError("func nonZeroMaxDeltaRangesAndDeltas came up with invalid deltas.")
            }
            var lastResultDone = false
            if deltaAtPosition != deltaAtPosition.zero {
                if let _ = headIndex, deltaForRangeHere = deltaForRange {
                    if deltaForRangeHere * deltaAtPosition < deltaAtPosition.zero {
                        lastResultDone = true
                    }
                }
                else {
                    headIndex = i
                }
                if !lastResultDone {
                    deltaForRange = (deltaForRange == nil) ? deltaAtPosition : min(deltaForRange!, deltaAtPosition)
                }
            }
            else {
                lastResultDone = true
            }
            tailIndex = i
            if deltaAtPosition != deltaAtPosition.zero && <#T##Collection corresponding to your index##Collection#>.index(after: tailIndex?) == endIndex {
                tailIndex = <#T##Collection corresponding to your index##Collection#>.index(after: tailIndex?)
                lastResultDone = true
            }
            if lastResultDone {
                if let start = headIndex, end = tailIndex, deltaHere = deltaForRange {
                    results.append((start..<end, deltaHere))
                }
                headIndex = nil
                tailIndex = nil
                deltaForRange = nil
                if deltaAtPosition != deltaAtPosition.zero {
                    headIndex = i
                    deltaForRange = deltaAtPosition
                }
            }
        }
        return results
    }
    /// Returns a new 'Array' with elements in 'range' modified by 'delta'.
    @warn_unused_result
    func apply(_ delta: Iterator.Element, to range: Range<Index>) -> [Iterator.Element] {
        var deltas: [Iterator.Element] = []
        deltas.append(Repeated(((startIndex..<range.startIndex).count as! Int), count: delta.zero))
        deltas.append(Repeated(((range.startIndex..<range.endIndex).count as! Int), count: delta))
        deltas.append(Repeated(((range.endIndex..<endIndex).count as! Int), count: delta.zero))
        var newNumbers: [Iterator.Element] = []
        var deltasGen = deltas.makeIterator()
        for number in self {
            newNumbers.append(number + deltasGen.next()!)
        }
        return newNumbers
    }
    
}

extension Array where Element : Numberable {
    @warn_unused_result
    func deltasAndRangesWithNewArrays(from collection: [Element], deltaPicker: ([(CountableRange<Int>, Element)]) -> (CountableRange<Int>, Element)?) -> (deltas: [Iterator.Element], ranges: [CountableRange<Int>], newArrays: [[Element]])? {
        var deltas: [Iterator.Element] = []
        var ranges: [CountableRange<Int>] = []
        var newArrays: [[Element]] = []
        var newCollection = collection
        var numberOfOptions = nonZeroMaxDeltaRangesAndDeltas(from: collection)?.count ?? 0
        while numberOfOptions > 0 {
            if let options = nonZeroMaxDeltaRangesAndDeltas(from: newCollection) {
                numberOfOptions = options.count
                if numberOfOptions > 0 {
                    guard let pick = deltaPicker(options)
                        else { return nil }
                    deltas.append(pick.1)
                    ranges.append(pick.0)
                    newCollection = (newArrays.last ?? collection).apply(pick.1, to: pick.0)
                    newArrays.append(newCollection)
                }
            }
            else {
                return nil
            }
        }
        return (deltas, ranges, newArrays)
    }
}

