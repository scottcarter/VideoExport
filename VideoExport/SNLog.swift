//
//  SNLog.swift
//  VideoExport
//

import Foundation

// Insert a warning in the Issue Navigator with the signature 'SNLog.Fixme'.
//
// Usage:
// g_fixme = g_anyFixme as SNLog.Fixme
//
// Warning reads:
// Treating a forced downcast to 'SNLog.Fixme' as optional will never produce 'nil'
//
var g_anyFixme: AnyObject? = SNLog.Fixme()
var g_fixme: SNLog.Fixme?



// Log a message and optionally insert a warning in the Issue Navigator with the signature 'SNLog'
//
// Usage with Issue Navigator warning:
// g_log = SNLog.log("<message>") as SNLog
// g_log = SNLog.info("<message>") as SNLog
// g_log = SNLog.error("<message>") as SNLog
//
// Warning reads:
// Treating a forced downcast to 'SNLog' as optional will never produce 'nil'
//
//
// Usage without Issue Navigator warning:
// SNLog.log("<message>")
// SNLog.info("<message>")
// SNLog.error("<message>")
//
// Note:
// In a closure that returns Void, a call to SNLog.[log|info|error] (which returns AnyObject) cannot
// be the last statement. If you need to return Void, try something like:
//
// SNLog.info("<message>")
// Void()
//
var g_log: SNLog?





class SNLog {
    
    class Fixme { }
    
    // The log() method calls display() with no prefix
    class func log (message: String, filePath: String = __FILE__, function: String = __FUNCTION__,  line: Int32 = __LINE__) -> AnyObject {
        return display("", message: message, filePath: filePath, function: function, line: line)
    }
    
    // The info() method calls display() with the prefix "INFO: "
    class func info (message: String, filePath: String = __FILE__, function: String = __FUNCTION__,  line: Int32 = __LINE__) -> AnyObject {
        return display("INFO: ", message: message, filePath: filePath, function: function, line: line)
    }
    
    // The error() method calls display() with the prefix "ERROR: "
    class func error (message: String, filePath: String = __FILE__, function: String = __FUNCTION__,  line: Int32 = __LINE__) -> AnyObject {
        return display("ERROR: ", message: message, filePath: filePath, function: function, line: line)
    }

    private class func display (prefix: String, message: String, filePath: String, function: String,  line: Int32) -> AnyObject {
        let file: String = filePath.lastPathComponent
        
        println("\(prefix)\(file) - \(function)(\(line)):\n \(message)\n")
        
        return SNLog()
    }
    
}

