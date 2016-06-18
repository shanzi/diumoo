//
//  DMNotificationCenter.swift
//  diumoo
//
//  Created by Yancheng Zheng on 6/18/16.
//
//

import Foundation
import AppKit

public class DMNotificationCenter : NSObject, NSUserNotificationCenterDelegate  {
 
    let pref = UserDefaults.standard()
    let NCCenter = NSUserNotificationCenter.default()
    
    public func userNotificationCenter(_ center: NSUserNotificationCenter, shouldPresent notification: NSUserNotification) -> Bool {
        return true
    }
    
    override init() {
        super.init()
        NSUserNotificationCenter.default().delegate = self
    }
    
    deinit {
        NSUserNotificationCenter.default().delegate = nil
    }
    
    func isNotificationON() -> Bool {
        return Int(self.pref.value(forKey: "enableNotification") as! NSNumber) == NSOnState
    }
    
    public func notifyMusicPlayback(withItem item: DMPlayableItem) {
        if isNotificationON() {
            let detail = String("\(item.musicInfo["artist"]!) - <\(item.musicInfo["albumtitle"]!)>")
            let aNotification = NSUserNotification.init()
            aNotification.title = item.musicInfo["title"] as? String
            aNotification.informativeText = detail
            aNotification.contentImage = item.cover
            aNotification.soundName = nil
            self.NCCenter.deliver(aNotification)
        }
        
        if Int(self.pref.value(forKey: "displayAlbumCoverOnDock") as! NSNumber) == NSOnState {
            NSApplication.shared().applicationIconImage = item.cover
        }
    }
    
    public func notifyBitrate() {
        if isNotificationON() {
            let title = NSLocalizedString("BITRATE_CHANGED", comment: "Music bitrate changed.")
            var detail = NSLocalizedString("BITRATE_CHANGED_TO_VALUE", comment: "Music bitrate changed to.")
            let quality = pref.value(forKey: "musicQuality") as? Int
            detail.append(String("\(quality!) Kbps"))
            
            let aNotification = NSUserNotification.init()
            aNotification.title = title
            aNotification.informativeText = detail
            aNotification.soundName = nil
            
            self.NCCenter.deliver(aNotification)
            
        }
    }
    
    public func clearNotifications() {
        self.NCCenter.removeAllDeliveredNotifications()
    }
    
    public func copylinkNotification (URLStr: String) {
        if isNotificationON() {
            let title = NSLocalizedString("SHARE_LINK_TITLE", comment: "share link")
            
            let aNotification = NSUserNotification.init()
            
            aNotification.title = title
            aNotification.informativeText = URLStr
            aNotification.soundName = nil
            
            self.NCCenter.deliver(aNotification)
        }
        
    }
}
