//
//  InsertNewLineBelow.swift
//  FBXCodeExtensionApp
//
//  Created by 李翔 on 11/18/16.
//  Copyright © 2016 Xiang Li. All rights reserved.
//

import Foundation
import XcodeKit


class InsertNewLineBelow: NSObject, XCSourceEditorCommand {

    func perform(with invocation: XCSourceEditorCommandInvocation, completionHandler: @escaping (Error?) -> Void ) -> Void {
        let lines = invocation.buffer.lines
        let selections = invocation.buffer.selections
        guard let selection = selections.firstObject as? XCSourceTextRange else {
            completionHandler(nil)
            return;
        }

        let currentLine = selection.end.line

        // insert new line below the current line
        let newLine = "\n";
        lines.insert(newLine, at: currentLine + 1)

        // move cursor to the new line
        let newCursorPosition = XCSourceTextPosition(line: currentLine + 1, column: 0)
        let newSelection = XCSourceTextRange(start: newCursorPosition, end: newCursorPosition)
        invocation.buffer.selections.removeAllObjects()
        invocation.buffer.selections.add(newSelection)

        completionHandler(nil)
    }
    
}
