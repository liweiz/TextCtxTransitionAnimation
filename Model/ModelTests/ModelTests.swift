//
//  ModelTests.swift
//  ModelTests
//
//  Created by Liwei Zhang on 2016-06-07.
//  Copyright © 2016 Liwei Zhang. All rights reserved.
//

import XCTest
@testable import Model

class ModelTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func test_Extension_CountabeRange_range_Int() {
        struct Test {
            let testName: String
            let selfRange: CountableRange<Int>
            let in_anotherCountableRange: CountableRange<Int>
            let for_rangeInSelf: CountableRange<Int>
            let expectedOutput: CountableRange<Int>?
        }
        let rangeA = 0..<100
        let rangeB = 50..<1000
        let rangeC = -99..<(-60)
        let rangeD = 0..<0
        let toTest = [
            Test(testName: "Range provided out of bounds of both base and in.", selfRange: rangeA, in_anotherCountableRange: rangeB, for_rangeInSelf: 1000..<1001, expectedOutput: nil),
            Test(testName: "Range provided out of bounds of base.", selfRange: rangeA, in_anotherCountableRange: rangeC, for_rangeInSelf: -9..<20, expectedOutput: nil),
            Test(testName: "Range provided out of bounds of in.", selfRange: rangeA, in_anotherCountableRange: rangeC, for_rangeInSelf: 87..<90, expectedOutput: nil),
            Test(testName: "Range provided falls in both bounds of base and in.", selfRange: rangeA, in_anotherCountableRange: rangeC, for_rangeInSelf: 23..<30, expectedOutput: -76..<(-69)),
            Test(testName: "Empty range provided falls in both bounds of base and in.", selfRange: rangeD, in_anotherCountableRange: rangeD, for_rangeInSelf: 0..<0, expectedOutput: 0..<0),
            Test(testName: "Non-empty base.", selfRange: rangeB, in_anotherCountableRange: rangeB, for_rangeInSelf: 150..<150, expectedOutput: 150..<150),
            Test(testName: "Empty range provided out of bounds of both base and in.", selfRange: rangeB, in_anotherCountableRange: rangeB, for_rangeInSelf: 0..<0, expectedOutput: nil)
        ]
        let testFuncName = "Extension_Range.range_Int"
        var i = 0
        for t in toTest {
            testNonCollectionEqualWithLog(t.selfRange.range(in: t.in_anotherCountableRange, for: t.for_rangeInSelf), expression2: t.expectedOutput, testFuncName: testFuncName, testName: t.testName, testIndex: i)
            i += 1
        }
    }
    

    
}
