//
//  Created by Tomaz Kragelj on 11.11.15.
//  Copyright © 2015 Gentle Bytes. All rights reserved.
//

import Foundation

/** Parses all source files in the command line arguments.
*/
class Parser: Task {
	
	// MARK: - Task
	
	/** Launches parsing tasks.
	
	Note that it's required to assign `settings` and `store` prior to calling this function!
	*/
	func run() throws {
		gtaskstart()
		ginfo("Parsing")
		
		for path in settings.arguments {
			let pathInfo = PathInfo(path: path as! String)
			try parsePathOrFile(pathInfo)
		}
		
		gtaskend()
	}
	
	// MARK: - Parsing handling
	
	private func parsePathOrFile(path: PathInfo) throws {
		if NSFileManager.defaultManager().isPathDirectory(path.fullPath) {
			gverbose("Scanning \(path.path)")
			try parseFolder(path)
		} else {
			gdebug("Scanning \(path.path)")
			try parseFile(path)
		}
	}
	
	private func parseFolder(path: PathInfo) throws {
		let subpathNames = try NSFileManager.defaultManager().contentsOfDirectoryAtPath(path.fullPath)
		for subpathName in subpathNames {
			switch subpathName {
			case ".": break
			case "..": break
			default:
				let subpath = path.path.stringByAppendingPathComponent(subpathName)
				let subpathInfo = PathInfo(path: subpath)
				try parsePathOrFile(subpathInfo)
				break
			}
		}
	}
	
	private func parseFile(path: PathInfo) throws {
		switch path.path.pathExtension {
		case "h": try parseObjectiveCFromFile(path)
		case "m": try parseObjectiveCFromFile(path)
		case "mm": try parseObjectiveCFromFile(path)
		default: break // Ignore everything else
		}
	}
	
	private func parseObjectiveCFromFile(path: PathInfo) throws {
		gverbose("Parsing \(path) as Objective-C")
		objectiveCParser.path = path
		try objectiveCParser.run()
	}
	
	// MARK: - Derived properties
	
	lazy var objectiveCParser: ObjectiveCParser = {
		let result = ObjectiveCParser()
		result.settings = self.settings
		result.store = self.store
		return result
	}()
	
	// MARK: - Properties
	
	/// Application settings. This must be assigned prior to using the object!
	var settings: Settings!
	
	/// Application objects store. This must be assigned prior to using the object!
	var store: Store!
	
}