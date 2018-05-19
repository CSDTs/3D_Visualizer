//
//  SceneViewModel.swift
//  CSDTModelViewer
//
//  Created by Jing Wei Li on 4/12/18.
//  Copyright © 2018 Jing Wei Li. All rights reserved.
//

import Foundation
import SceneKit
import SceneKit.ModelIO
import UIKit

// converison to MVC in progress
class SceneViewModel: NSObject{
    var lightingControl: SCNNode!
    var wigwaam: SCNNode!
    var cameraNode: SCNNode!
    var customURL = "None"
    var modelObject: MDLMesh!
    var modelNode: SCNNode!
    var modelAsset: MDLAsset!{ didSet{ setUp() } }
    var ARModelScale: Float = 0.07
    var ARRotationAxis: String = "X"
    var selectedColor: UIColor = UIColor.clear
    var IntensityOrTemperature = true
    var isFromWeb = false
    var blobLink: URL? = nil
    
    override init() {
        super.init()
    }
    
    func setUp(){
    
    }
    
    
}
