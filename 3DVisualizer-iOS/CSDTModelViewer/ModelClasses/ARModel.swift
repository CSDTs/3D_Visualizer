//
//  ARModel.swift
//  CSDTModelViewer
//
//  Created by Jing Wei Li on 4/10/18.
//  Copyright © 2018 Jing Wei Li. All rights reserved.
//

import Foundation
import ARKit
import SceneKit
import SceneKit.ModelIO
import UIKit

class ARModel:NSObject{
    var model: MDLMesh!
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
    var planeDirection: String!
    
    override init() {
        super.init()
    }
    
    func configureHitTest(with hit:ARHitTestResult){
        if isThreeD{
            nodeToUse = SCNNode(mdlObject: model)
        } else {
            let geometry = SCNBox(width: 300, height: 300, length: 0.01, chamferRadius: 0)
            geometry.firstMaterial?.diffuse.contents = twoDImage
            nodeToUse = SCNNode(geometry: geometry)
            switch planeDirection{
            case "Horizontal":
                nodeToUse.runAction(SCNAction.rotateBy(x: CGFloat.pi/2, y: 0, z: 0, duration: 0.0001))
            case "Vertical":
                nodeToUse.runAction(SCNAction.rotateBy(x: CGFloat.pi, y: 0, z: 0, duration: 0.0001))
            default: break
            }
        }
        
        nodeToUse.scale = SCNVector3Make(modelScale, modelScale, modelScale)
        nodeToUse.position = SCNVector3Make(hit.worldTransform.columns.3.x, hit.worldTransform.columns.3.y, hit.worldTransform.columns.3.z)
        nodeToUse.geometry?.firstMaterial?.blendMode = stringToBlendMode[blendSettings]!
        isModelAdded = true
    }
    
    func handleRotation(with rotation:CGFloat){
        let rotationAngle = rotation - previousRotationAngle
        switch rotationAxis{
        case "X":
            nodeToUse.runAction(SCNAction.rotateBy(x: rotationAngle * 0.1, y: 0, z: 0, duration: 0.0001))
        case "Y":
            nodeToUse.runAction(SCNAction.rotateBy(x: 0, y: rotationAngle * -0.1, z: 0, duration: 0.0001))
        case "Z":
            nodeToUse.runAction(SCNAction.rotateBy(x: 0, y: 0, z: rotationAngle * 0.1, duration: 0.0001))
        default:
            nodeToUse.runAction(SCNAction.rotateBy(x: 0, y: rotationAngle * 0.1, z: 0, duration: 0.0001))
        }
        previousRotationAngle = rotationAngle
    }
    
    func handleZoom(with sender:UIPinchGestureRecognizer){
        guard isModelAdded else { return }
        switch sender.state {
        case .changed:
            let zoomFactor = Float(sender.scale * 0.001) + Float(prevZoomScale)
            nodeToUse.scale = SCNVector3Make(zoomFactor, zoomFactor, zoomFactor)
        case .ended:
            prevZoomScale = sender.scale * 0.001
        default: break
        }
    }
    
    func handlePlaneAddition(usingAnchor planeAnchor: ARPlaneAnchor, andNode node:SCNNode?){
        
        //indicates a plane
        let geometry = SCNBox(width: CGFloat(planeAnchor.extent.x), height: planeHeight, length: CGFloat(planeAnchor.extent.z), chamferRadius: 2.0)
        geometry.firstMaterial?.diffuse.contents = UIColor.green
        geometry.firstMaterial?.specular.contents = UIColor.white
        geometry.firstMaterial?.transparency = 0.7
        let newPlane = SCNNode(geometry: geometry)
        newPlane.position = SCNVector3Make(planeAnchor.center.x, Float(planeHeight/2), planeAnchor.center.z)
        
        lightingControl.light = SCNLight()
        lightingControl.light?.type = .directional//stringToLightType[lightSettings]!
        lightingControl.light?.intensity = 10000
        lightingControl.position = SCNVector3Make(242, 100, 118)
        lightingControl.light?.color = lightColor
        isPlaneAdded = true
        
        node?.addChildNode(lightingControl)
        node?.addChildNode(newPlane)
    }
    
    func handleNodeUpdates(with node:SCNNode, andAnchor planeAnchor: ARPlaneAnchor){
        if node.childNodes.count > 0{
            let planeNode = node.childNodes.first!
            planeNode.position = SCNVector3Make(planeAnchor.center.x, Float(planeHeight/2), planeAnchor.center.z)
            if let box = planeNode.geometry as? SCNBox{
                if isModelAdded{
                    box.firstMaterial?.transparency = 0.0
                } else {
                    box.width = CGFloat(planeAnchor.extent.x)
                    box.length = CGFloat(planeAnchor.extent.z)
                    box.height = planeHeight
                }
            }
            guard isModelAdded else { return }
            if node.childNodes.count > 1{
                let model = node.childNodes[0]
                model.position = SCNVector3Make(planeAnchor.center.x, planeAnchor.center.y, planeAnchor.center.z)
                model.scale = SCNVector3Make(modelScale, modelScale, modelScale)
                let plane = node.childNodes[1]
                plane.geometry?.firstMaterial?.transparency = 0.0
            }
        }
    }
    
}
