//
//  ARModel.swift
//  CSDTModelViewer
//
//  Created by Jing Wei Li on 4/12/18.
//  Copyright © 2018 Jing Wei Li. All rights reserved.
//

import Foundation
import ARKit

class ARModel{
    var sceneView:ARSCNView!
    var isModelAdded = false
    var isPlaneAdded = false
    let lightingControl = SCNNode()
    var lightSettings: String!
    var blendSettings: String!
    var animationSettings: animationSettings!
    var nodeToUse: SCNNode!
    var lightColor: UIColor!
    let planeHeight:CGFloat = 0.01
    var modelScale: Float = 0.07
    var previousRotationAngle: CGFloat = 0
    var rotationAxis: String!
    var prevZoomScale: CGFloat = 0
    var isThreeD = true
    var twoDImage: UIImage?
    
    init(onScene scene: ARSCNView) {
        sceneView = scene
    }
    
    func hitTest(){
        
    }
    
    
    
    
}
