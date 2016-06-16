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
    
//    func test_Extension_Range_range() {
//        struct Tests {
//            let testName: String
//            let in_anotherRange: Range<Int>
//            let for_rangeInSelf: Range<Int>
//            let expectedOutput: Range<Int>?
//        }
//        let selfRange = 0..<100
//        let toTests = [
//            Tests(testName: "normal", in_anotherRange: 100..<500, for_rangeInSelf: 34..<47, expectedOutput: 134..<147),
//            Tests(testName: "nil", in_anotherRange: 10..<20, for_rangeInSelf: 34..<35, expectedOutput: nil)
//        ]
//        let testFuncName = "Extension_Range.range"
//        var i = 0
//        for t in toTests {
//            testNonCollectionEqualWithLog(selfRange.range(in: t.in_anotherRange, for: t.for_rangeInSelf), expression2: t.expectedOutput, testFuncName: testFuncName, testName: t.testName, testIndex: i)
//            i += 1
//        }
//    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock {
            // Put the code you want to measure the time of here.
        }
    }
    
}
