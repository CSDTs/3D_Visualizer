//
//  JSONFetch.swift
//  CSDTModelViewer
//
//  Created by Jing Wei Li on 4/12/18.
//  Copyright © 2018 Jing Wei Li. All rights reserved.
//

import Foundation

struct JSONFetch{
    
    /**
     
     */
    static func fetchFromCSDTServer(with data: Any?) -> [(String, String, String, String, String)]{
        guard let jsonData = data as? [Dictionary<String, Any>] else { return [] }
        var temp: [(String, String, String, String, String)] = []
        for fetchedData in jsonData{
            var dataEntry: (String, String, String, String,String)
                = ("Unknown","Unknown","Unknown", "https://csdt.rpi.edu","Unknown")
            if let id = fetchedData["application"] as? Int {
                guard id == 38 else { continue }
            }
            if let name = fetchedData["name"] as? String{
                dataEntry.0 = name.capitalized
            }
            if let descrip = fetchedData["description"] as? String{
                dataEntry.1 = descrip
            }
            if let imageURL = fetchedData["screenshot_url"] as? String{
                dataEntry.2 = "https://csdt.rpi.edu" + imageURL
            }
            if let projectURL = fetchedData["project_url"] as? String{
                dataEntry.4 = "https://csdt.rpi.edu" + projectURL
            }
            dataEntry.3 = "https://csdt.rpi.edu/"
            temp.append(dataEntry)
        }
        return temp
    }
    
}
