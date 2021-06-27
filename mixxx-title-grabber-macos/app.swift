//
//  app.swift
//  mixxx-title-grabber-macos
//
//  Created by apple on 6/26/21.
//

import Foundation
import AppKit

class Application {
    
    var mixxxPID: pid_t = 0
    var mixxxWindowID: Int32 = 0
    let kTimerInterval: Double = 0.150
    let kFilename: String = "nowPlaying-mixxx.txt"
    var lastTrackTitle: String = ""
    var filepath: String = ""
    init(){
        filepath =  Utils.appendFilepath(toPath: Utils.documentDirectory()
                                         , withPathComponent: self.kFilename)! as String
    }
    
    func main()-> Void{
        let workspace = NSWorkspace.shared

        let runningApps = workspace.runningApplications

        for app in runningApps{
            if (app.bundleIdentifier == "org.mixxx.mixxx"){
                mixxxPID = app.processIdentifier
                break
            }
        }

        if (mixxxPID == 0){
            print("Mixxx is not running.")
            exit(0)
        }

        let windowList = CGWindowListCopyWindowInfo(CGWindowListOption.optionOnScreenOnly, kCGNullWindowID) as! Array<CFDictionary>
        for window in windowList{
            let windowDict = window as NSDictionary
            let parentPID = windowDict[kCGWindowOwnerPID] as! Int32
            if(parentPID == mixxxPID){
                Utils.ensureScreenRecordingCheckboxIsChecked(appWindow: window)
                mixxxWindowID = windowDict[kCGWindowNumber] as! Int32
                break
            }
        }
        print("Polling every " + String(kTimerInterval) + " seconds.")
        print("Saving to " + filepath)
        _ = Timer.scheduledTimer(withTimeInterval: 0.250, repeats: true, block: self.timerInvocation)
        RunLoop.main.run()
    }
    
    func grabMixxxTitle()-> String{
        let windowList = CGWindowListCopyWindowInfo(CGWindowListOption.optionOnScreenOnly, kCGNullWindowID) as! Array<CFDictionary>
        for window in windowList{
            let windowDict = window as NSDictionary
            let windowID = windowDict[kCGWindowNumber] as! Int32
            if(windowID == mixxxWindowID){
                let mixxxTitle: String = (windowDict[kCGWindowName] as! String)
                if (mixxxTitle.count <= 5){
                    return ""
                }
                let trimedTitle: String = String(mixxxTitle.dropLast(8))
                return trimedTitle
            }
        }
        return "EXIT"
    }
    
    func writeMetadata(title: String) -> Bool{
        do{
            try title.write(toFile: filepath, atomically: true, encoding: String.Encoding.utf8)
        }catch{
            print("Error", error)
            return false
        }
        return true
    }
    
    
    func timerInvocation(timer: Timer) -> Void{
        let title = grabMixxxTitle()
        if(title == "EXIT"){
            print("Mixxx exited")
            exit(0)
        }
        if (title != self.lastTrackTitle){
            var modifiedLastTrack = self.lastTrackTitle
            if(self.lastTrackTitle == ""){
                modifiedLastTrack = "No Track Playing"
            }
            print("Track changed: " + modifiedLastTrack + " -> " + title)
            let writeResult = writeMetadata(title: title)
            if(!writeResult){
                print("write failed!")
            }
            self.lastTrackTitle = title
        }
    }
}
