//
//  DuplicateLines.swift
//  FBXCodeExtensionApp
//
//  Created by 李翔 on 11/7/16.
//  Copyright © 2016 Xiang Li. All rights reserved.
//

import Foundation
import XcodeKit

class DuplicateLines: NSObject, XCSourceEditorCommand {

    func perform(with invocation: XCSourceEditorCommandInvocation, completionHandler: @escaping (Error?) -> Void ) -> Void {
        let lines = invocation.buffer.lines
        let selections = invocation.buffer.selections

        for selection in selections {
            if let selection = selection as? XCSourceTextRange {
                let startingLine = selection.start.line
                let endingLine = min(selection.end.line, lines.count - 1)

                let duplicationRange = NSRange(location: startingLine, length: endingLine - startingLine + 1)
                let subLines = lines.subarray(with: duplicationRange)
                let subLinesCopy = NSArray.init(array: subLines, copyItems: true)
                for (lineIndex, aLine) in subLinesCopy.enumerated() {
                    lines.insert(aLine, at: lineIndex + endingLine + 1)
                }

                // move selections down
                let linesAdded = selection.end.line - selection.start.line + 1
                selection.start = XCSourceTextPosition(line:selection.end.line + 1, column: selection.start.column)
                selection.end = XCSourceTextPosition(line:selection.end.line + linesAdded, column: selection.end.column)
            }
        }

        completionHandler(nil)
    }

}
