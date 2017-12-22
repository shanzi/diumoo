//
//  DMPlaylistFetcher.swift
//  diumoo
//
//  Created by Yancheng Zheng on 6/18/16.
//
//

import Foundation
import AppKit

@objc public protocol DMPlaylistFetcherDeleate {
    func fetchPlaylist(WithDictionary dict:Dictionary<String, AnyObject>, startAttribute attribute: String, errorThreshould errCount: NSInteger) -> Void
    func fetchPlaylistSucess(startSong: DMPlayableItem?) -> Void
}

public class DMPlaylistFetcher : NSObject{
    // This should actually be an enum type
    // But Objective-C does not support String type enum
    // This is all we can do
    // FIXME: When project convert to Swift completely
    static public let kFetchPlaylistTypeNew = "n"
    static public let kFetchPlaylistTypeEnd = "e"
    static public let kFetchPlaylistTypePlaying = "p"
    static public let kFetchPlaylistTypeSkip = "s"
    static public let kFetchPlaylistTypeRate = "r"
    static public let kFetchPlaylistTypeUnrate = "u"
    static public let kFetchPlaylistTypeBye = "b"
    
    static internal let PLAYLIST_FETCH_URL_BASE = "https://douban.fm/j/mine/playlist"
    static internal let DOUBAN_FM_ORIGIN_URL    = ".douban.fm"
    static internal let DOUBAN_ALBUM_GET_URL    = "https://douban.fm/j/app/radio/people"
    
    public var delegate : DMPlaylistFetcherDeleate?
    
    internal var playlist : Array<Dictionary<String, AnyObject>> = []
    internal var playedSongs : Dictionary<String, String> = [:]
    internal var searchResults : NSOrderedSet = []
    
    internal func randomString() -> String {
        let rand1 : UInt32 = arc4random();
        let rand2 : UInt32 = arc4random();
        return String(format:"%5x%5x",((rand1 & 0xfffff) | 0x10000),rand2)
    }
    
    deinit {
        self.playlist.removeAll()
        self.playedSongs.removeAll()
        self.delegate = nil
    }
    
    public func fetchPlaylist(fromChannel channel: String, Type type: String, sid : String?, startAttribute attribute: String?) {
        var newType = type
        if newType == DMPlaylistFetcher.kFetchPlaylistTypeEnd && self.playlist.count == 0 {
            newType = DMPlaylistFetcher.kFetchPlaylistTypeNew
        } else if sid == nil {
            newType = DMPlaylistFetcher.kFetchPlaylistTypeNew
        } else {
            self.playedSongs[sid!] = type
        }
        
        let pref = UserDefaults.standard
        let quality = pref.value(forKey: "musicQuality") as! NSNumber
        
        let fetchDictionary : Dictionary<String, AnyObject> = [
                                                          "type": type as AnyObject,
                                                       "channel": Int(channel) as AnyObject,
                                                           "sid": ((sid != nil) ? sid : "") as AnyObject,
                                                             "h": self.playedSongs.hString() as AnyObject,
                                                             "r": self.randomString() as AnyObject,
                                                          "from": "mainsite" as AnyObject,
                                                          "kbps": quality]
        self.fetchPlaylist(withDictionary: fetchDictionary, startAttribute: attribute, errCount: 0)
    }
    
    public func fetchPlaylist(withDictionary dict: Dictionary<String, AnyObject>, startAttribute attribute: String?, errCount: Int) {
        let urlString = DMPlaylistFetcher.PLAYLIST_FETCH_URL_BASE.appendingFormat("?%@", dict.urlEncodedString())
        let urlRequest = URLRequest.init(url: URL.init(string: urlString)!, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 20.0)
        
        // Processing cookie
        let validAttr = attribute ?? ""
        let cookie = HTTPCookie.init(properties: [HTTPCookiePropertyKey.domain: "douban.fm",
                                                    HTTPCookiePropertyKey.name: "start",
                                                   HTTPCookiePropertyKey.value: validAttr,
                                                 HTTPCookiePropertyKey.discard: true,
                                                    HTTPCookiePropertyKey.path:"/"])
        
        HTTPCookieStorage.shared.setCookie(cookie!)
        
        let session = URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            if error != nil {
                self.delegate?.fetchPlaylist(WithDictionary: dict, startAttribute: validAttr, errorThreshould: errCount + 1)
            } else {
                do {
                    let jResponse = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers)
                    
                    let strRet = jResponse as? String
                    if strRet == "ok" {
                        self.delegate?.fetchPlaylistSucess(startSong: nil)
                    } else {
                        let jDict = jResponse as! Dictionary<String, AnyObject>
                        let jrVal = jDict["r"] as! Int
                        
                        // Something's wrong
                        if jrVal != 0 {
                            self.delegate?.fetchPlaylist(WithDictionary: dict, startAttribute: validAttr, errorThreshould: errCount + 1)
                        } else {
                            let jList = jDict["song"] as? Array<Dictionary<String, AnyObject>>
                            if attribute != nil {
                                self.playlist = jList!
                                let aSong = DMPlayableItem.init(WithDict: self.playlist[0])
                                self.delegate?.fetchPlaylistSucess(startSong: aSong)
                                self.playlist.remove(at: 0)
                            } else {
                                if let list = jList {
                                    self.playlist.append(contentsOf: list)
                                }
                                self.delegate?.fetchPlaylistSucess(startSong: nil)
                            }
                        }
                    }
                } catch _ {
                    self.delegate?.fetchPlaylist(WithDictionary: dict, startAttribute: validAttr, errorThreshould: errCount + 1)
                }
            }
        }
        session.resume()
    }
    
    public func getOnePlayableItem() -> DMPlayableItem? {
        if self.playlist.count > 0 {
            let songInfo = self.playlist[0]
            let subtype = songInfo["subtype"] as! String
            let filterAds = UserDefaults.standard.value(forKey: "filterAds") as! Int
            if  subtype == "T" && filterAds == NSOnState {
                self.playlist.remove(at: 0)
                return self.getOnePlayableItem()
            }
            
            self.playlist.remove(at: 0)
            return DMPlayableItem.init(WithDict: songInfo)
        } else {
            return nil
        }
    }
    
    public func clearPlaylist() {
        self.playlist.removeAll()
    }

    internal func sendRequest(forURL urlString: String, callback: @escaping (Array<Dictionary<String, AnyObject>>?)->Void){
        let url = URL.init(string: urlString)
        let request = URLRequest.init(url: url!, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 10.0)
        
        let session = URLSession.shared.dataTask(with: request) { data, response, error in
            if data != nil {
                do {
                    let jResponse = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers)
                    let albumDict = jResponse as! Dictionary<String, AnyObject>
                    let songArray = albumDict["song"] as? Array<Dictionary<String, AnyObject>>
                    callback(songArray)
                } catch {
                    print("\(#function) ::  Invalid Json returned from server")
                }
            }
        }
        session.resume()
    }
    
    public func fetchSongs(withMusician musicianID: String, callback:@escaping (Bool)->Void) {
         let dict = ["type" : DMPlaylistFetcher.kFetchPlaylistTypeNew,
                  "channel":Int(0),
                        "r": self.randomString(),
                     "from": "mainsite",
                  "context": String("context=channel:0|musician_id:\(musicianID)")!] as [String : Any]
        let urlString = String("\(DMPlaylistFetcher.PLAYLIST_FETCH_URL_BASE)?\(dict.urlEncodedString())")
        self.sendRequest(forURL: urlString!) { list in
            if list != nil {
                self.playlist.removeAll()
                self.playlist.append(contentsOf: list!)
                callback(true)
            } else {
                callback(false)
            }
        }
    }
    
    public func fetchSongs(withSoundtrackID songID: String, callback:@escaping (Bool)->Void) {
        let dict = ["type":DMPlaylistFetcher.kFetchPlaylistTypeNew,
                 "channel":Int(10),
                       "r":self.randomString(),
                    "from":"mainsite",
                 "context":String("context=channel:10|subject_id:\(songID)")!] as [String : Any]
        
        let urlstring = String("\(DMPlaylistFetcher.PLAYLIST_FETCH_URL_BASE)?\(dict.urlEncodedString())")

        self.sendRequest(forURL: urlstring!) { list in
            if list != nil {
                self.playlist.removeAll()
                self.playlist.append(contentsOf: list!)
                callback(true)
            } else {
                callback(false)
            }
        }
    }
    
    public func fetchSongs(withAlbum album: String, callback:@escaping (Bool)->Void) {
        let data = Date()
        let expire = Int(data.timeIntervalSince1970 + 1000 * 60 * 5 * 30)
        let dict = ["type" : DMPlaylistFetcher.kFetchPlaylistTypeNew,
                  "context": String("channel:0|subject_id:\(album)")!,
                  "channel":Int(0),
                 "app_name":"radio_ipad",
                  "version":"1",
                  "expire" : expire] as [String : Any]
        
        let urlstring = String("\(DMPlaylistFetcher.DOUBAN_ALBUM_GET_URL)?\(dict.urlEncodedString())")
        self.sendRequest(forURL: urlstring!) { list in
            if list != nil {
                var albumSong = [] as Array<Dictionary<String, AnyObject>>
                for song in list! {
                    if song["aid"] as! String == album {
                        albumSong.append(song)
                    }
                }
                if albumSong.count > 0 {
                    self.playlist = albumSong 
                    callback(true)
                } else {
                    callback(false)
                }
            }
        }

    }
}
