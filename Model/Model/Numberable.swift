//
//  Numberable.swift
//  TextCtxTransitionAnimation
//
//  Created by Liwei Zhang on 2016-05-26.
//  Copyright © 2016 Liwei Zhang. All rights reserved.
//

import Foundation

protocol Numberable: Comparable, Hashable {
    func +(lhs: Self, rhs: Self) -> Self
    func -(lhs: Self, rhs: Self) -> Self
    func *(lhs: Self, rhs: Self) -> Self
    func /(lhs: Self, rhs: Self) -> Self
    func %(lhs: Self, rhs: Self) -> Self
    var zero: Self { get }
}

extension Numberable {
    var zero: Self {
        return self - self
    }
}

extension Double: Numberable {}
extension Float: Numberable {}
extension Int: Numberable {}
extension Int8: Numberable {}
extension Int16: Numberable {}
extension Int32: Numberable {}
extension Int64: Numberable {}
extension UInt: Numberable {}
extension UInt8: Numberable {}
extension UInt16: Numberable {}
extension UInt32: Numberable {}
extension UInt64: Numberable {}

extension SequenceType where Generator.Element : Numberable {
    @warn_unused_result
    func dicWithFirstAsKeyRestAsValueArray() -> [Generator.Element: SubSequence]? {
        var gen = generate()
        guard let first = gen.next(), _ = gen.next() else {
            return nil
        }
        return [first: self.dropFirst()]
    }
}