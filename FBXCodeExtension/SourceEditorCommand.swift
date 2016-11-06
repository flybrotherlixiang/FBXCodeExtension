//
//  SourceEditorCommand.swift
//  FBXCodeExtension
//
//  Created by Xiang Li on 04/11/2016.
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
                
                // move selections to the line above the starting line
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
        
        if originStartingLine >= 0 && originStartingColumn >= 0 {
            let firstSelection = selections.firstObject as! XCSourceTextRange
            var newStart : XCSourceTextPosition
            if  originStartingLine >= lines.count - 1 {
                newStart = XCSourceTextPosition(line: max(lines.count - 1, 0), column: originStartingColumn)
            } else {
                newStart = XCSourceTextPosition(line: originStartingLine, column: originStartingColumn)
            }
            
            firstSelection.start = newStart
            firstSelection.end = newStart
        }
        
        completionHandler(nil)
    }
    
}
