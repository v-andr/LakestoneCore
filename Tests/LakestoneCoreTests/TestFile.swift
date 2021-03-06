//
//  TestFile.swift
//  LakestoneCore
//
//  Created by Taras Vozniuk on 9/29/16.
//  Copyright © 2016 GeoThings. All rights reserved.
//
// --------------------------------------------------------
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

#if COOPER
	
	import remobjects.elements.eunit
	
#else
	
	import XCTest
	import Foundation
	
	@testable import LakestoneCore
	
#endif

public class TestFile: Test {
	
	var workingDirectoryPath: String!
	
	#if COOPER
	override func Setup(){
		super.Setup()
		self.commonSetup()
	}
	#else
	override public func setUp() {
		super.setUp()
		self.commonSetup()
	}
	#endif
	
	func commonSetup() {
		
		#if COOPER
			self.workingDirectoryPath = MainActivity.currentInstance.getFilesDir().getCanonicalPath()
		#elseif os(iOS) || os(watchOS) || os(tvOS)
			if let documentsDirectoryPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, false).first {
				self.workingDirectoryPath = (documentsDirectoryPath as NSString).expandingTildeInPath
			}
		#else
			self.workingDirectoryPath = FileManager.default.currentDirectoryPath
		#endif
	}
	
	public func testFileOperations(){
		
		
		let sampleText = "Just come text for this test...º"
		let andSomeMoreText = "Yeah... more and more text"
		let overwriteText = "Text to overwrite"
		
		let testFileURL = URL(fileURLWithPath: workingDirectoryPath).appendingPathComponent("testFile.txt")
		let testFile = File(fileURL: testFileURL)
		
		let testCopyFileURL = URL(fileURLWithPath: workingDirectoryPath).appendingPathComponent("testCopyFile.txt")
		let testCopyFile = File(fileURL: testCopyFileURL)
		
		let testMoveFileURL = URL(fileURLWithPath: workingDirectoryPath).appendingPathComponent("testMoveFile.txt")
		let testMoveFile = File(fileURL: testMoveFileURL)
        
        let testFolderURL = URL(fileURLWithPath: workingDirectoryPath).appendingPathComponent("TestFolder")
        let testFolder = Directory(directoryURL: testFolderURL)
        
		do {
			if testFile.exists {
				try testFile.remove()
				Assert.IsFalse(testFile.exists)
			}
			if testCopyFile.exists {
				try testCopyFile.remove()
				Assert.IsFalse(testCopyFile.exists)
			}
			if testMoveFile.exists {
				try testMoveFile.remove()
				Assert.IsFalse(testMoveFile.exists)
			}
            if testFolder.exists {
                try testFolder.remove()
                Assert.IsFalse(testFolder.exists)
            }
			
			// MARK: test writing and overwriting text in the file
			try testFile.overwrite(with: sampleText)
			Assert.AreEqual(try testFile.readUTF8EncodedString(), sampleText)
			try testFile.overwrite(with: overwriteText)
			Assert.AreEqual(try testFile.readUTF8EncodedString(), overwriteText)
			try testFile.overwrite(with: sampleText)
			Assert.AreEqual(try testFile.readUTF8EncodedString(), sampleText)
			try testFile.append(utf8EncodedString: andSomeMoreText)
			Assert.AreEqual(try testFile.readUTF8EncodedString(), sampleText + andSomeMoreText)
			
			// MARK: test file to file copy and move
			try testCopyFile.overwrite(with: " ")
			var newFile = try testFile.copy(to: testCopyFile, overwrites: true)
            Assert.AreEqual(newFile.path, testCopyFile.path)
			Assert.AreEqual(try testCopyFile.readUTF8EncodedString(), sampleText + andSomeMoreText)
			
            try testMoveFile.overwrite(with: " ")
            newFile = try testCopyFile.move(to: testMoveFile, overwrites: true)
            Assert.AreEqual(newFile.path, testMoveFile.path)
			Assert.AreEqual(try testMoveFile.readUTF8EncodedString(), sampleText + andSomeMoreText)
            Assert.IsFalse(testCopyFile.exists)
            
            // existing files at the moment: testFile.txt, testMoveFile.txt
            
            // MARK: test file to folder copy and move
            try testFolder.create()
            newFile = try testFile.copy(to: testFolder, overwrites: true)
            Assert.AreEqual(newFile.name, testFile.name)
            let testFolderCopyFile = File(fileURL: newFile.url)
            Assert.AreEqual(try testFolderCopyFile.readUTF8EncodedString(), sampleText + andSomeMoreText)
            
            newFile = try testMoveFile.move(to: testFolder, overwrites: true)
            Assert.AreEqual(newFile.name, testMoveFile.name)
            let testFolderMoveFile = File(fileURL: newFile.url)
            Assert.AreEqual(try testFolderMoveFile.readUTF8EncodedString(), sampleText + andSomeMoreText)
            Assert.IsFalse(testMoveFile.exists)
            
            guard let parentCopyDirectory = testFolderCopyFile.parentDirectoryº else {
                Assert.Fail("Cannot get parent dir of copied file")
                return
            }
            Assert.AreEqual(parentCopyDirectory,testFolder)
            
            guard let parentMoveDirectory = testFolderMoveFile.parentDirectoryº else {
                Assert.Fail("Cannot get parent dir of moved file")
                return
            }
            Assert.AreEqual(parentMoveDirectory,testFolder)
            
            // existing files at the moment: testFile.txt, TestFolder/testFile.txt, TestFolder/testMoveFile.txt
			
			//MARK: test file properties
			Assert.AreEqual(testFile.name, "testFile")
			Assert.AreEqual(testFile.extension, "txt")
			Assert.IsFalse(testFile.isDirectory)
			
			//'º' is only character two bytes in size
			Assert.AreEqual(testFile.size, (sampleText + andSomeMoreText).characterCount + 1)
			guard let modificationDate = testFile.lastModificationDateº else {
				Assert.Fail("Cannot retrieve file last modification date")
				return
			}
			
			Assert.IsTrue(modificationDate.timeIntervalSince1970 < Date().timeIntervalSince1970 + 60.0)
			
			let sameFileInitedWithPath = File(path: testFileURL.path)
			Assert.IsTrue(sameFileInitedWithPath.exists)
			Assert.AreEqual(sameFileInitedWithPath.name, "testFile")
			Assert.AreEqual(sameFileInitedWithPath.extension, "txt")
			Assert.IsFalse(sameFileInitedWithPath.isDirectory)
			
			try sameFileInitedWithPath.remove()
			Assert.IsFalse(sameFileInitedWithPath.exists)
			
			guard let parentDirectory = testFile.parentDirectoryº else {
				Assert.Fail("Cannot retrieve parent directory (already root)")
				return
			}
			
			Assert.AreEqual(parentDirectory.path, self.workingDirectoryPath)

			let sameTestFile = File(fileURL: testFileURL)
			Assert.AreEqual(sameTestFile, testFile)
            
            // cleanup
            if testFolder.exists {
                try testFolder.remove()
                Assert.IsFalse(testFolder.exists)
            }
			
		} catch {
			Assert.Fail("File operation failed: \(error)")
		}
		
	}
	
}

#if !COOPER
extension TestFile {
	static var allTests : [(String, (TestFile) -> () throws -> Void)] {
		return [
			("testFileOperations", testFileOperations)
		]
	}
}
#endif
