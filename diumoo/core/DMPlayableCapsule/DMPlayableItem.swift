//
//  DMPlayableItem.swift
//  diumoo
//
//  Created by Anakin(Yancheng) Zheng on 6/18/16.
//
//

import Foundation
import AVFoundation

@objc public enum ItemPlayState : Int {
    case waitToPlay, playing, playing_and_will_replay, replaying, replayed
}

@objc public protocol DMPlayableItemDelegate {
    func playableItem(_ item: DMPlayableItem, logStateChanged: Int) -> (Void)
}

public class DMPlayableItem: AVPlayerItem {
    // Interface variables
    public var cover : NSImage?
    public var like : Bool
    private(set) public var musicInfo : [String: AnyObject]!
    public var playState: ItemPlayState
    public var delegate: DMPlayableItemDelegate?
    
    public var floatDuration: Float {
        get {
            return Float(CMTimeGetSeconds(self.asset.duration))
        }
    }
    
    // Const variables
    let douban_URL_prefix = "https://music.douban.com"
    let timer_interval = 0.1
    
    init(WithDict aDict: Dictionary<String, AnyObject>) {
        self.musicInfo = [ "subtype":aDict["subtype"]!,
                             "title":aDict["title"]!,
                            "artist":aDict["artist"]!,
                        "albumtitle":aDict["albumtitle"]!,
                     "musicLocation":aDict["url"]!,
                   "pictureLocation":aDict["picture"]!]
        
        let pic = String(aDict["picture"]!)
        self.musicInfo["largePictureLocation"] = pic.replacingOccurrences(of:"mpic", with:"lpic")

        if aDict["aid"] != nil {
            self.musicInfo["aid"] = aDict["aid"]!
            self.musicInfo["sid"] = aDict["sid"]!
            self.musicInfo["ssid"] = aDict["ssid"]!
            self.musicInfo["length"] = Float(String(aDict["length"]!))! * 1000
            self.musicInfo["albumLocation"] = String("\(douban_URL_prefix)\(String(aDict["album"]))")
        }
        
        self.like = NSString(string: String(aDict["like"]!)).boolValue
        self.playState = ItemPlayState.waitToPlay
        self.cover = nil
        
        let dictURL = String(aDict["url"]!)
        let aURL  = URL(string: dictURL)
        let aAsset = AVAsset(url: aURL!)
        super.init(asset: aAsset, automaticallyLoadedAssetKeys: nil)
        
        self.addObserver(self, forKeyPath:"status", options: NSKeyValueObservingOptions(rawValue: UInt(0)), context: nil)
    }
    
    public func invalidItem() {
        self.playState = ItemPlayState.waitToPlay
        self.removeObserver(self, forKeyPath:"status")
    }
    
    override public func observeValue(forKeyPath keyPath: String?, of object: AnyObject?, change: [NSKeyValueChangeKey : AnyObject]?, context: UnsafeMutablePointer<Void>?) {
        if keyPath == "status" {
            print("\(#function) :: \(musicInfo["title"]!) status changed to \(self.status)")
            self.delegate?.playableItem(self, logStateChanged: self.status.rawValue)
        }
    }
    
    public func shareAttributeWithChannel(_ channel: String) -> String? {
        if self.musicInfo["ssid"] != nil {
            return String(format:"%@g%@g%@",String(self.musicInfo["sid"]), String(self.musicInfo["ssid"]), channel)
        } else {
            return nil
        }
    }
    
    public func prepareCoverWithCallbackBlock(_ block: (NSImage?)->Void) {
        if self.cover != nil {
            block(self.cover!)
            return
        }
        
        let strURL = String(musicInfo["largePictureLocation"]!)
        let aURL = URL(string: strURL)
        let request = URLRequest(url: aURL!, cachePolicy: .useProtocolCachePolicy , timeoutInterval: 5.0)
        
        let session = URLSession.shared().dataTask(with: request) { data, response, error in
            if error != nil || data == nil {
                print("\(#function) failed to get album image with reason \(error)")
                self.cover = #imageLiteral(resourceName: "albumfail")
            } else {
                self.cover = NSImage(data: data!)
            }
            block(self.cover)
        }        
        session.resume()
    }
    
    deinit {
        self.delegate = nil
        self.invalidItem()
    }
    
    class func playableItem(WithDictionary aDict: Dictionary<String, AnyObject>) -> DMPlayableItem {
        return DMPlayableItem.init(WithDict: aDict)
    }
}
