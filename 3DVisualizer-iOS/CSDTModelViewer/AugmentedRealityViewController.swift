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
    let scene = SCNScene()
    var isModelAdded = false
    let lightingControl = SCNNode()
    var lightSettings: String!
    var blendSettings: String!
    var animationSettings: animationSettings!
    var nodeToUse: SCNNode!
    var lightColor: UIColor!
    
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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        configuration.worldAlignment = .gravityAndHeading
        
        // Run the view's session
        sceneView.session.run(configuration)
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
        let touchLocation = sender.location(in: sceneView)
        
        if let hit = sceneView.hitTest(touchLocation, types: .featurePoint).first{
            sceneView.session.add(anchor: ARAnchor(transform: hit.worldTransform))
            DispatchQueue.main.async { overlayTextWithVisualEffect(using: "Success", on: self.view)}
        } else {
            DispatchQueue.main.async { overlayTextWithVisualEffect(using: "Try Again", on: self.view)}
        }
    }
    
    @IBAction func changeLightPosition(_ sender: UIPanGestureRecognizer) {
        guard isModelAdded else { return }
        let location = sender.location(in: sceneView)
        lightingControl.position = SCNVector3Make(Float(location.x), Float(location.y), 100)
    }
    
    // MARK: - ARSCNViewDelegate
    
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        var node: SCNNode?
        
        if let planeAnchor = anchor as? ARPlaneAnchor{
            if !isModelAdded{
                DispatchQueue.main.async { overlayTextWithVisualEffect(using: "Surface Recognized", on: self.view)}
                node = SCNNode()
                nodeToUse = SCNNode(mdlObject: model)
                nodeToUse.scale = SCNVector3Make(0.3, 0.3, 0.3)
                nodeToUse.position = SCNVector3Make(planeAnchor.center.x, planeAnchor.center.y, planeAnchor.center.z)
                nodeToUse.geometry?.firstMaterial?.blendMode = stringToBlendMode[blendSettings]!
            
                lightingControl.light = SCNLight()
                lightingControl.light?.type = stringToLightType[lightSettings]!
                lightingControl.light?.color = UIColor.white
                lightingControl.light?.intensity = 2000
                lightingControl.position = SCNVector3Make(0, 50, 50)
                lightingControl.light?.color = lightColor
                
                node?.addChildNode(lightingControl)
                node?.addChildNode(nodeToUse)
                isModelAdded = true
                
                let nodeToAnimate = node?.childNodes.first
                if nodeToAnimate != nil {
                    switch animationSettings{
                    case .rotate:
                        nodeToAnimate!.runAction(SCNAction.repeatForever(SCNAction.rotateBy(x: 0, y: 2, z: 0, duration: 4)))
                    default: break
                    }
                }
            }
        }        
        return node
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard isModelAdded else { return }
        if let planeAnchor = anchor as? ARPlaneAnchor{
            node.position = SCNVector3Make(planeAnchor.center.x, planeAnchor.center.y, planeAnchor.center.z)
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

}
