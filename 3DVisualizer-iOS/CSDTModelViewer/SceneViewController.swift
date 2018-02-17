//
//  SceneViewController.swift
//  CSDTModelViewer
//
//  Created by Jing Wei Li on 2/1/18.
//  Copyright © 2018 Jing Wei Li. All rights reserved.
//

import UIKit
import SceneKit
import ModelIO
import SceneKit.ModelIO
import ARKit

class SceneViewController: UIViewController {
    @IBOutlet weak var sceneView: SCNView!
    @IBOutlet weak var intensitySlider: UISlider!
    @IBOutlet weak var modelLoadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var ARButton: UIButton!
    var lightingControl: SCNNode!
    var wigwaam: SCNNode!
    var cameraNode: SCNNode!
    var customURL = "None"
    var modelObject: MDLMesh!
    var modelNode: SCNNode!
    var modelAsset: MDLAsset!{ didSet{ setUp() } }
    var ARModelScale: Float = 0.07
    var ARRotationAxis: String = "X"
    
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return .default
    }
    
    var animationMode: animationSettings = .none{
        didSet{
            guard animationMode != oldValue else { return }
            wigwaam.removeAllActions()
            switch  animationMode {
            case .rotate:
                wigwaam.runAction(SCNAction.repeatForever(SCNAction.rotateBy(x: 0, y: 2, z: 0, duration: 4)))
            default: break
            }
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        modelLoadingIndicator.tintColor = UIColor.white
        modelLoadingIndicator.startAnimating()
        navigationController?.setNavigationBarHidden(true, animated: true)
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            if self?.customURL != "None"{
                guard let url = URL(string: (self?.customURL)!) else {
                    fatalError("failed to open model file")
                }
                DispatchQueue.main.async { self?.modelAsset = MDLAsset(url: url) }
            } else {
                let url = Bundle.main.url(forResource: "wigwaam", withExtension: "stl")!
                DispatchQueue.main.async { self?.modelAsset = MDLAsset(url: url)}
                self?.ARModelScale = 0.002
            }
            
        }
        // hides the ar button if Augmented Reality is not supported on the device.
        if !ARWorldTrackingConfiguration.isSupported {
            ARButton.isHidden = true
        }
    }
    
    fileprivate func setUp(){
        if let object = modelAsset.object(at: 0) as? MDLMesh { // valid model object from link
            modelObject = object
        } else { // invalid model, fall back to default model
            let url = Bundle.main.url(forResource: "wigwaam", withExtension: "stl")!
            let asset = MDLAsset(url: url)
            modelObject = asset.object(at: 0) as! MDLMesh
            let alertController = UIAlertController(title: "Error",
                                                    message: "Error loading url, falling back to default model",
                                                    preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            alertController.view.tintColor = customGreen()
            self.present(alertController, animated: true, completion: nil)
            ARModelScale = 0.002
        }
        
        let scene = SCNScene()
        
        modelNode = SCNNode(mdlObject: modelObject)
        modelNode.scale = SCNVector3Make(2, 2, 2)
        modelNode.geometry?.firstMaterial?.blendMode = .alpha
        
        scene.rootNode.addChildNode(modelNode)
        
        lightingControl = SCNNode()
        lightingControl.light = SCNLight()
        lightingControl.light?.type = .omni
        lightingControl.light?.color = UIColor.white
        lightingControl.light?.intensity = 2000
        lightingControl.position = SCNVector3Make(0, 50, 50)
        scene.rootNode.addChildNode(lightingControl)
        
        let camera = SCNCamera()
        camera.usesOrthographicProjection = true
        camera.orthographicScale = 9;
        camera.zNear = 0;
        camera.zFar = 100;
        cameraNode = SCNNode()
        cameraNode.position = SCNVector3Make(50, 50, 50)
        scene.rootNode.addChildNode(cameraNode)
        
//        let floor = SCNFloor()
//        floor.reflectionFalloffEnd = 10
//        floor.reflectivity = 0.8
//        let floorNode = SCNNode(geometry: floor)
//        floorNode.position = SCNVector3(x: 0, y: -10.0, z: 0)
//        scene.rootNode.addChildNode(floorNode)
        
        sceneView.autoenablesDefaultLighting = true
        sceneView.allowsCameraControl = true
        sceneView.scene = scene
        sceneView.backgroundColor = UIColor.white
        
        wigwaam = scene.rootNode.childNodes.first!
        modelLoadingIndicator?.stopAnimating()
        modelLoadingIndicator?.isOpaque = true
    }
    
    @IBAction func changeModelColor(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            lightingControl.light?.color = UIColor.red
        case 1:
            lightingControl.light?.color = UIColor.orange
        case 2:
            lightingControl.light?.color = UIColor.green
        case 3:
            lightingControl.light?.color = UIColor.yellow
        default:
            break
        }
    }
    
    @IBAction func changeLightIntensity(_ sender: UISlider) {
        lightingControl.light?.intensity = CGFloat(sender.value)
    }
    @IBAction func changeLightLocation(_ sender: UITapGestureRecognizer) {
        let ctr = sender.location(in: sceneView)
        lightingControl.position = SCNVector3Make(Float(ctr.x), Float(ctr.y), 100)
    }
    
    @IBAction func exitSceneView(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func updateSceneSettings(from segue:UIStoryboardSegue){
        if let settings = segue.source as? SceneSettingsTableViewController{
            modelNode.geometry?.firstMaterial?.blendMode = stringToBlendMode[settings.selectedBlendSetting]!
            lightingControl.light?.type = stringToLightType[settings.selectedLightSetting]!
            animationMode = settings.selectedAnimationSetting
            ARModelScale = settings.ARModelScale
            ARRotationAxis = settings.ARRotationAxis
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        var destinationViewController = segue.destination
        if let navigationViewController = destinationViewController as? UINavigationController {
            destinationViewController = navigationViewController.visibleViewController ?? destinationViewController
        }
        if let dest = destinationViewController as? SceneSettingsTableViewController{
            dest.lightSettings = determineLightType(with: lightingControl.light!)
            dest.blendSettings = determineBlendMode(with: modelNode.geometry!.firstMaterial!.blendMode)
            dest.animationMode = animationMode
            dest.ARModelScale = ARModelScale
            dest.ARRotationAxis = ARRotationAxis
        }
        if let dest = destinationViewController as? AugmentedRealityViewController{
            dest.model = modelObject
            dest.lightSettings = determineLightType(with: lightingControl.light!)
            dest.blendSettings = determineBlendMode(with: modelNode.geometry!.firstMaterial!.blendMode)
            dest.animationSettings = animationMode
            dest.lightColor = lightingControl.light!.color as! UIColor
            dest.modelScale = ARModelScale
            dest.rotationAxis = ARRotationAxis
        }
    }
}

