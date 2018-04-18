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
    @IBOutlet weak var sceneView: ARSCNView!
    @IBOutlet weak var statusBackground: UIVisualEffectView!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var doneButton: UIButton!
    
    var ar:ARModel!
    
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
        sceneView.scene = SCNScene()
        statusBackground.clipsToBounds = true
        statusBackground.layer.cornerRadius = 10.0
        //ar = ARModel()
        configureDropShadow(with: doneButton)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = stringToPlaneDetection[ar.planeDirection]!
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
        guard !ar.isModelAdded else { return }
        let touchLocation = sender.location(in: sceneView)
        if let hit = sceneView.hitTest(touchLocation, types: .featurePoint).first{
            sceneView.session.add(anchor: ARAnchor(transform: hit.worldTransform))
            DispatchQueue.main.async { overlayTextWithVisualEffect(using: "Success", on: self.view) }
            ar.configureHitTest(with: hit)
            sceneView.scene.rootNode.addChildNode(ar.nodeToUse)
        } else {
            DispatchQueue.main.async { overlayTextWithVisualEffect(using: "Try Again", on: self.view)}
        }
    }
    
    @IBAction func changeLightPosition(_ sender: UIPanGestureRecognizer) {
        guard ar.isModelAdded else { return }
        let location = sender.location(in: sceneView)
        ar.lightingControl.position = SCNVector3Make(Float(location.x), 100, Float(location.y))
        //statusLabel.text = "\(location.x),100,\(location.y)"
    }
    
    @IBAction func rotateModel(_ sender: UIRotationGestureRecognizer) {
        guard ar.isModelAdded else { return }
        if sender.state == .changed{
            ar.handleRotation(with: sender.rotation)
        }
    }
    
    @IBAction func zoomModel(_ sender: UIPinchGestureRecognizer) {
        ar.handleZoom(with: sender)
    }
    
    @IBAction func resetAR(_ sender: UIButton) {
        sceneView.session.pause()
        sceneView.scene.rootNode.enumerateChildNodes { node, _ in
            node.removeFromParentNode()
        }
        ar.isModelAdded = false
        ar.isPlaneAdded = false
        // Run the view's session
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = stringToPlaneDetection[ar.planeDirection]!
        configuration.worldAlignment = .gravityAndHeading
        configuration.isLightEstimationEnabled = true
        sceneView.session.run(configuration, options: [.removeExistingAnchors, .resetTracking])
        
    }
    // MARK: - ARSCNViewDelegate
    
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        var node: SCNNode?
        
        if let planeAnchor = anchor as? ARPlaneAnchor{
            if !ar.isModelAdded && !ar.isPlaneAdded{
                DispatchQueue.main.async { overlayTextWithVisualEffect(using: "Surface Recognized", on: self.view) }
                node = SCNNode()
                ar.handlePlaneAddition(usingAnchor: planeAnchor, andNode: node)
            }
        }        
        return node
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        //guard isModelAdded else { return }
        if let planeAnchor = anchor as? ARPlaneAnchor{
            ar.handleNodeUpdates(with: node, andAnchor: planeAnchor)
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
            case .relocalizing:
                statusLabel.text = "Resuming"
            }
        }
    }

}
