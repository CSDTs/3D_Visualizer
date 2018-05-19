//
//  ThreeDDataModel.swift
//  CSDTModelViewer
//
//  Created by Jing Wei Li on 4/10/18.
//  Copyright © 2018 Jing Wei Li. All rights reserved.
//

import Foundation

struct ThreeDDataModel{
    
    static func obtainDefaultModelURL() -> ([URL],[String]) {
        var modelNames: [String] = []
        let modelsURL = Bundle.main.url(forResource: "Models", withExtension: nil)!
        let fileEnumerator = FileManager().enumerator(at: modelsURL, includingPropertiesForKeys: [])!
        let results:[URL] =  fileEnumerator.compactMap{ element in
            let url = element as! URL
            //guard url.pathExtension == "stl" else { return nil }
            modelNames.append(url.lastPathComponent)
            return url
        }
        return (results,modelNames)
    }
    
    static func obtainSavedModelURL() -> ([URL], [String]){
        let fileManager = FileManager.default
        var results: [URL] = []
        var modelNames:[String] = []
        do {
            let directory = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            let fileEnumerator = FileManager().enumerator(at: directory, includingPropertiesForKeys: [])!
            while let element = fileEnumerator.nextObject() as? URL{
                if (element.lastPathComponent == "Inbox") { continue }
                results.append(element)
                modelNames.append(element.lastPathComponent)
            }
        } catch {
            return ([],modelNames)
        }
        return (results,modelNames)
    }
}
