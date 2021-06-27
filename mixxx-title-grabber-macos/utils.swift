//
//  utils.swift
//  mixxx-title-grabber-macos
//
//  Created by apple on 6/26/21.
//
import AppKit
class Utils {
    
    // https://github.com/shaqed/alt-tab-macos/blob/ecca47e696136758df4ee7a528b1ed7cb2379f84/alt-tab-macos/ui/Application.swift
    static func ensureScreenRecordingCheckboxIsChecked(appWindow: CFDictionary) {
            let windowDict = appWindow as Dictionary
            let windowOwnerPID = windowDict[kCGWindowNumber] // window[kCGWindowOwnerPID]
            
            // Try getting the image
            let windowImage = CGWindowListCreateImage(.null, .optionIncludingWindow, windowOwnerPID as! CGWindowID, [.boundsIgnoreFraming, .bestResolution])
            
            // If nil, permission denied (this will also prompt for permission)
            // Should this fail, just exit
            if windowImage == nil{
                print("Cannot get screen recording permission. This is needed to grab the title.")
                exit(0)
            }
            
    }
    
    //https://programmingwithswift.com/save-file-to-documents-directory-with-swift/
    static func documentDirectory() -> String {
        let documentDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory,
                                                                    .userDomainMask,
                                                                    true)
        return documentDirectory[0]
    }
    
    static func appendFilepath(toPath path: String,
                        withPathComponent pathComponent: String) -> String? {
        if var pathURL = URL(string: path) {
            pathURL.appendPathComponent(pathComponent)
            
            return pathURL.absoluteString
        }
        
        return nil
    }

}
