//
//  AugmentedRealityViewController.swift
//  CSDTModelViewer
//
//  Created by Jing Wei Li on 2/3/18.
//  Copyright © 2018 Jing Wei Li. All rights reserved.
//

import UIKit
import ARKit
import SceneKit
import ModelIO
import SceneKit.ModelIO

class AugmentedRealityViewController: UIViewController, ARSCNViewDelegate {
    var model: MDLMesh!
    @IBOutlet weak var sceneView: ARSCNView!
    @IBOutlet weak var statusBackground: UIVisualEffectView!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var doneButton: UIButton!
    let scene = SCNScene()
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
    
    @IBAction func exitARSession(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return .lightContent
    }
    
    override func viewDidLoad() {
        sceneView.delegate = self
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        // Set the scene to the view
        sceneView.automaticallyUpdatesLighting = true
        sceneView.scene = scene
        statusBackground.clipsToBounds = true
        statusBackground.layer.cornerRadius = 10.0

        configureDropShadow(with: doneButton)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        configuration.worldAlignment = .gravityAndHeading
        configuration.isLightEstimationEnabled = true
        
        // Run the view's session
        sceneView.session.run(configuration, options: [.removeExistingAnchors, .resetTracking])
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
    
    // MARK: - Gesture Recognizers
    
    @IBAction func hitTestWithTap(_ sender: UITapGestureRecognizer) {
        guard !isModelAdded else { return }
        let touchLocation = sender.location(in: sceneView)
        if let hit = sceneView.hitTest(touchLocation, types: .featurePoint).first{
            sceneView.session.add(anchor: ARAnchor(transform: hit.worldTransform))
            DispatchQueue.main.async { overlayTextWithVisualEffect(using: "Success", on: self.view) }
            
            if isThreeD{
                nodeToUse = SCNNode(mdlObject: model)
            } else {
                let geometry = SCNBox(width: 300, height: 300, length: 0.01, chamferRadius: 0)
                geometry.firstMaterial?.diffuse.contents = twoDImage
                nodeToUse = SCNNode(geometry: geometry)
                nodeToUse.runAction(SCNAction.rotateBy(x: CGFloat.pi/2, y: 0, z: 0, duration: 0.0001))
            }
            
            nodeToUse.scale = SCNVector3Make(modelScale, modelScale, modelScale)
            nodeToUse.position = SCNVector3Make(hit.worldTransform.columns.3.x, hit.worldTransform.columns.3.y, hit.worldTransform.columns.3.z)
            nodeToUse.geometry?.firstMaterial?.blendMode = stringToBlendMode[blendSettings]!
            sceneView.scene.rootNode.addChildNode(nodeToUse)
            isModelAdded = true
        } else {
            DispatchQueue.main.async { overlayTextWithVisualEffect(using: "Try Again", on: self.view)}
        }
    }
    
    @IBAction func changeLightPosition(_ sender: UIPanGestureRecognizer) {
        guard isModelAdded else { return }
        let location = sender.location(in: sceneView)
        lightingControl.position = SCNVector3Make(Float(location.x), 100, Float(location.y))
        //statusLabel.text = "\(location.x),100,\(location.y)"
    }
    
    @IBAction func rotateModel(_ sender: UIRotationGestureRecognizer) {
        guard isModelAdded else { return }
        if sender.state == .changed{
            let rotationAngle = sender.rotation - previousRotationAngle
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
    }
    
    @IBAction func zoomModel(_ sender: UIPinchGestureRecognizer) {
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
    
    // MARK: - ARSCNViewDelegate
    
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        var node: SCNNode?
        
        if let planeAnchor = anchor as? ARPlaneAnchor{
            if !isModelAdded && !isPlaneAdded{
                DispatchQueue.main.async { overlayTextWithVisualEffect(using: "Surface Recognized", on: self.view)}
                node = SCNNode()
                
                //indicates a plane
                let geometry = SCNBox(width: CGFloat(planeAnchor.extent.x), height: planeHeight, length: CGFloat(planeAnchor.extent.z), chamferRadius: 2.0)
                geometry.firstMaterial?.diffuse.contents = UIColor.green
                geometry.firstMaterial?.specular.contents = UIColor.white
                geometry.firstMaterial?.transparency = 0.7
                let newPlane = SCNNode(geometry: geometry)
                newPlane.position = SCNVector3Make(planeAnchor.center.x, Float(planeHeight/2), planeAnchor.center.z)
                
                lightingControl.light = SCNLight()
                lightingControl.light?.type = stringToLightType[lightSettings]!
                lightingControl.light?.color = UIColor.white
                lightingControl.light?.intensity = 2000
                lightingControl.position = SCNVector3Make(242, 100, 118)
                lightingControl.light?.color = lightColor
                
                node?.addChildNode(lightingControl)
                node?.addChildNode(newPlane)
                
                let nodeToAnimate = node?.childNodes.first
                if nodeToAnimate != nil {
                    switch animationSettings{
                    case .rotate:
                        nodeToAnimate!.runAction(SCNAction.repeatForever(SCNAction.rotateBy(x: 0, y: 2, z: 0, duration: 4)))
                    default: break
                    }
                }
                isPlaneAdded = true
            }
        }        
        return node
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        //guard isModelAdded else { return }
        if let planeAnchor = anchor as? ARPlaneAnchor{
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
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        DispatchQueue.main.async { overlayTextWithVisualEffect(using: "Failed", on: self.view)}
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        DispatchQueue.main.async { overlayTextWithVisualEffect(using: "Interrupted", on: self.view)}
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        DispatchQueue.main.async { overlayTextWithVisualEffect(using: "Resumed", on: self.view)}
    }
    
    func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
        switch camera.trackingState {
        case  .notAvailable:
            statusLabel.text = "Not Available"
        case .normal:
            statusLabel.text = "Normal"
        case .limited(let reason):
            switch reason{
            case .initializing:
                statusLabel.text = "Initializing"
            case .excessiveMotion:
                statusLabel.text = "Slow Down"
            case .insufficientFeatures:
                statusLabel.text = "Insufficient Features"
            }
        }
    }

}
