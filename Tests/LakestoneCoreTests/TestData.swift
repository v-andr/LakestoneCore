﻿//
//  TestData.swift
//  LakestoneCore
//
//  Created by Taras Vozniuk on 9/26/16.
//
//

#if COOPER
	
	import remobjects.elements.eunit
	
#else
	
	import XCTest
	import Foundation
	
	#if os(iOS) || os(watchOS) || os(tvOS)
		@testable import LakestoneCoreIOS
	#else
		@testable import LakestoneCore
	#endif
	
#endif

class TestData: Test {
	
	public func testNumericConversion(){
		
		let testNumber: Int64 = 534098634643643
		
		let littleEndianData = Data.with(long: testNumber, usingLittleEndianEncoding: true)
		let bigEndianData = Data.with(long: testNumber, usingLittleEndianEncoding: false)
		
		guard let targetLENumber = littleEndianData.longRepresentation(withLittleEndianByteOrder: true),
			  let targetBENumber = bigEndianData.longRepresentation(withLittleEndianByteOrder: false)
		else {
			Assert.Fail("Data cannot be represented in long decimal")
			return
		}
		
		let testNumberBytesBE = [Int8]([0x00, 0x01, 0xE5, 0xC2, 0x87, 0x64, 0x98, 0xBB].map {
			Int8(bitPattern: $0)
		})
		
		for (index, byte) in littleEndianData.bytes.enumerated() {
			Assert.AreEqual(byte, [Int8](testNumberBytesBE.reversed())[index])
		}
		
		for (index, byte) in bigEndianData.bytes.enumerated() {
			Assert.AreEqual(byte, testNumberBytesBE[index])
		}
		
		Assert.AreEqual(targetLENumber, testNumber)
		Assert.AreEqual(targetBENumber, testNumber)
		
	}
	
	public func testUTF8StringWrapping(){
		
		let testString = "ºººUTF-8 TestStringººº"
		let testData = Data.with(utf8EncodedString: testString)
		guard let targetString = testData?.utf8EncodedStringRepresentation else {
			Assert.Fail("Data cannot be represented as utf8-encoded string")
			return
		}
		
		Assert.AreEqual(testString, targetString)
	}
	
}

#if !COOPER
	extension TestData {
		static var allTests : [(String, (TestData) -> () throws -> Void)] {
			return [
				("testNumericConversion", testNumericConversion),
				("testUTF8StringWrapping", testUTF8StringWrapping)
			]
		}
	}
#endif
