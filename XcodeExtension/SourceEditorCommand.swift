//
//  SourceEditorCommand.swift
//  TotsuzenNoShi
//
//  Created by Safx Developer on 2016/07/11.
//  Copyright © 2016 Safx Developers. All rights reserved.
//

import Foundation
import XcodeKit

class SourceEditorCommand: NSObject, XCSourceEditorCommand {
    
    func perform(with invocation: XCSourceEditorCommandInvocation, completionHandler: (NSError?) -> Void ) -> Void {
        let textBuffer = invocation.buffer

        let uti = textBuffer.contentUTI
        let tab = textBuffer.tabWidth
        let indent = textBuffer.indentationWidth
        let useTab = textBuffer.usesTabsForIndentation

        let cb = textBuffer.completeBuffer
        let lines = textBuffer.lines
        let selections = textBuffer.selections

        print("----------------------")
        print(uti, tab, indent, useTab)
        print("--------")
        print(lines)
        print("--------")
        print(selections)

        guard let selection = selections.firstObject as? XCSourceTextRange else {
            completionHandler(NSError(domain: "TotsuzenNoShi", code: 401, userInfo: ["reason": "text not selected"]))
            return
        }

        guard selection.start.line == selection.end.line else {
            completionHandler(NSError(domain: "TotsuzenNoShi", code: 402, userInfo: ["reason": "single line expected"]))
            return
        }

        let line = selection.start.line
        let start = selection.start.column
        let end = selection.end.column
        let length = end - start

        guard length > 0 else {
            completionHandler(NSError(domain: "TotsuzenNoShi", code: 403, userInfo: ["reason": "text not selected"]))
            return
        }

        guard var body = lines[line].description else {
            completionHandler(NSError(domain: "TotsuzenNoShi", code: 444, userInfo: ["reason": "unknown error"]))
            return
        }

        func mkString(count: Int, repeatString: String, begin: String = "", end: String = "") -> String {
            let body = (0...count).map { e in repeatString }.joined(separator: "")
            return begin + body + end
        }

        let pad = mkString(count: start, repeatString: " ")
        let header = pad + mkString(count: (length * 115 / 100) / 2 + 1, repeatString: "人", begin: "＿", end: "＿")
        let footer = pad + mkString(count: length / 2, repeatString: "Y^", begin: "￣", end: "Y￣")

        let sp = body.index(body.startIndex, offsetBy: start)
        let ep = body.index(body.startIndex, offsetBy: end)
        let ep1 = body.index(body.startIndex, offsetBy: end + 1)
        let body0 = body.substring(to: sp)
        let body1 = body[sp...ep]
        let body2 = body.substring(from: ep1)
        let modifiedBody = "\(body0) ＞ \(body1) ＜ \(body2)"

        lines.insert(header, at: line)
        lines[line + 1] = modifiedBody
        lines.insert(footer, at: line + 2)

        completionHandler(nil)
    }
    
}
