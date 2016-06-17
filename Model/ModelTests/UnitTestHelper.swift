//
//  UnitTestHelper.swift
//  StringExtractor
//
//  Created by Liwei Zhang on 2016-03-19.
//  Copyright © 2016 Liwei Zhang. All rights reserved.
//

import XCTest

internal let testHead = "TEST_NAME "
internal let testStartNotice = " *** START"
internal let testFuncMultiReturn = " * Return."
internal let testEndNotice = " *** END"

internal func printStart(_ testFuncName: String, testName: String, testIndex: Int) {
    print(testHead + "\(testIndex): " + testFuncName + " *** " + testName + testStartNotice)
}
internal func printFuncReturn(_ testFuncName: String, testName: String, testIndex: Int, returnIndex: Int) {
    print(testHead + "\(testIndex): " + testFuncName + " *** " + testName + testFuncMultiReturn + "\(returnIndex)")
}
internal func printEnd(_ testFuncName: String, testName: String, testIndex: Int) {
    print(testHead + "\(testIndex): " + testFuncName + " *** " + testName + testEndNotice)
}
internal func testArrayEqualWithLog<T: Equatable>(_ expression1: [T?], expression2: [T?], testFuncName: String, testName: String, testIndex: Int) {
    printStart(testFuncName, testName: testName, testIndex: testIndex)
    var i = 0
    for t in expression1 {
        printFuncReturn(testFuncName, testName: testName, testIndex: testIndex, returnIndex: i)
        XCTAssertEqual(t, expression2[i])
        i += 1
    }
    printEnd(testFuncName, testName: testName, testIndex: testIndex)
}
internal func testNonCollectionEqualWithLog<T: Equatable>(_ expression1: T?, expression2: T?, testFuncName: String, testName: String, testIndex: Int) {
    printStart(testFuncName, testName: testName, testIndex: testIndex)
    XCTAssertEqual(expression1, expression2)
    printEnd(testFuncName, testName: testName, testIndex: testIndex)
}
internal func testIsNilWithLog<T>(_ expression: T?, testFuncName: String, testName: String, testIndex: Int) {
    printStart(testFuncName, testName: testName, testIndex: testIndex)
    XCTAssertNil(expression)
    printEnd(testFuncName, testName: testName, testIndex: testIndex)
}
internal func testTwoElemTupleEqualWithLog<T: Equatable, U: Equatable>(_ expression1: (T, U), expression2: (T, U), testFuncName: String, testName: String, testIndex: Int) {
    printStart(testFuncName, testName: testName, testIndex: testIndex)
    printFuncReturn(testFuncName, testName: testName, testIndex: testIndex, returnIndex: 0)
    XCTAssertEqual(expression1.0, expression2.0)
    printFuncReturn(testFuncName, testName: testName, testIndex: testIndex, returnIndex: 1)
    XCTAssertEqual(expression1.1, expression2.1)
    printEnd(testFuncName, testName: testName, testIndex: testIndex)
}
