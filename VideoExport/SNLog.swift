//
//  SNLog.swift
//  VideoExport
//

import Foundation

// These variables can be used to insert a warning with the signature 'Fixme'.
// Example:
// g_fixme = g_anyFixme as Fixme
//
// Warning reads:
// Treating a forced downcast to 'Fixme' as optional will never produce 'nil'
//
var g_anyFixme: AnyObject? = Fixme()
var g_fixme: Fixme?


// Used in conjunction with a call to SNLog.info to both log and create a warning
// with the signature 'SNLog'
//
// Example with warning:
// g_log = SNLog.info("") as SNLog
//
// Warning reads:
// Treating a forced downcast to 'SNLog' as optional will never produce 'nil'
//
// Example without warning:
// SNLog.info("")
//
var g_log: SNLog?



class Fixme { }

class SNLog {
    
    
    // The error() method prefixes "ERROR:" and calls info()
    class func error (message: String, filePath: String = __FILE__, function: String = __FUNCTION__,  line: Int32 = __LINE__) -> AnyObject {
        let newMessage = "ERROR: " + message
        return info(newMessage, filePath: filePath, function: function, line: line)
    }
    
    
    // Note:
    // In a function that returns Void, a call to SNLog.info (which returns AnyObject) cannot
    // be last statement. Instead use:
    //
    // SNLog.info("<message>")
    // Void()
    class func info (message: String, filePath: String = __FILE__, function: String = __FUNCTION__,  line: Int32 = __LINE__) -> AnyObject {
        let file: String = filePath.lastPathComponent
        
        println("\(file) - \(function)(\(line)):\n \(message)\n")
        
        return SNLog()
    }
    
    
}

