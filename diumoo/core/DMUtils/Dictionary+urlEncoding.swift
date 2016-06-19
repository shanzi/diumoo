//
//  Dictionary+urlEncoding.swift
//  diumoo
//
//  Created by Yancheng Zheng on 6/18/16.
//
//

import Foundation

extension Dictionary {
    
    static func toString(_ object: Any) -> String {
        return String(object);
    }
    
    static func urlEncode(_ object: Any) -> String {
        let inputString = toString(object);
        return inputString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
    }

    
    func urlEncodedString() -> String {
        var parts : Array<String> = []
        for (key, value) in self {
            let encodedkey = Dictionary.urlEncode(key)
            let encodedVal = Dictionary.urlEncode(value)
            let part = String("\(encodedkey)=\(encodedVal)")
            parts.append(part)
        }
        return parts.joined(separator: "&")
    }
    
    func hString() -> String {
        var parts : Array<String> = []
        for (key, value) in self {
            let part = String("\(Dictionary.toString(key)):\(Dictionary.toString(value))")
            parts.append(part)
        }
        return parts.joined(separator: "|")
    }
}

