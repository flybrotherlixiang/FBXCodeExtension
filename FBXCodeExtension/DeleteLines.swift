//
//  DeleteLines.swift
//  FBXCodeExtensionApp
//
//  Created by 李翔 on 11/7/16.
//  Copyright © 2016 Xiang Li. All rights reserved.
//

import Foundation
import XcodeKit

class DeleteLines: NSObject, XCSourceEditorCommand {

    func perform(with invocation: XCSourceEditorCommandInvocation, completionHandler: @escaping (Error?) -> Void ) -> Void {
        let lines = invocation.buffer.lines
        let selections = invocation.buffer.selections
        var originStartingLine = -1
        var originStartingColumn = -1

        for (index, selection) in selections.enumerated() {
            if let selection = selection as? XCSourceTextRange {
                let startingLine = selection.start.line
                let endingLine = min(selection.end.line, lines.count - 1)
                let deletionRange = NSRange(location: startingLine, length: endingLine - startingLine + 1)

                // move [selections] to the line above the starting line before we operate on the [lines] in case it crashes...
                // note : in case of multi-selections, tweaking the first selection will do the trick
                if index == 0 {
                    originStartingLine = selection.start.line
                    originStartingColumn = selection.start.column
                    var newLine = selection.start.line - 1
                    var newColumn = selection.start.column
                    if newLine < 0 {
                        newLine = 0
                        newColumn = 0
                    }
                    let newStart = XCSourceTextPosition(line: newLine, column: newColumn)
                    selection.start = newStart
                    selection.end = newStart
                }

                // delete selected lines
                lines.removeObjects(in: deletionRange)
            }
        }

        // move selections back
        if originStartingLine >= 0 && originStartingColumn >= 0 {
            let firstSelection = selections.firstObject as! XCSourceTextRange

            var newStartingLine, newStartingColumn : Int
            if  originStartingLine >= lines.count - 1 {
                newStartingLine = max(lines.count - 1, 0)
            } else {
                newStartingLine = originStartingLine
            }

            if lines.count > 0 {
                let newStartingLineLength = (lines.object(at: newStartingLine) as! NSString).length
                if originStartingColumn > newStartingLineLength - 1 {
                    newStartingColumn = newStartingLineLength - 1
                } else {
                    newStartingColumn = originStartingColumn
                }
            } else {
                newStartingLine = 0
                newStartingColumn = 0
            }

            let newStart = XCSourceTextPosition(line: newStartingLine, column: newStartingColumn)
            firstSelection.start = newStart
            firstSelection.end = newStart
        }
        
        completionHandler(nil)
    }
    
}

