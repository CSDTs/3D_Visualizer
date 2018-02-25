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

class SceneViewController: UIViewController, UIPopoverPresentationControllerDelegate {
    @IBOutlet weak var sceneView: SCNView!
    @IBOutlet weak var intensitySlider: UISlider!
    @IBOutlet weak var modelLoadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var ARButton: UIButton!
    @IBOutlet weak var colorSegments: UISegmentedControl!
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
        if let dest = destinationViewController as? ColorPickerCollectionView{
            dest.selectedColor = lightingControl.light?.color as! UIColor
            if let ppc = segue.destination.popoverPresentationController{
                ppc.delegate = self
            }
        }
    }
    
    @IBAction func getColorFromPicker(with segue: UIStoryboardSegue){
        if(selectedColor != lightingControl.light?.color as! UIColor){
            colorSegments.selectedSegmentIndex = -1 // deselect the segment if different
        }
        lightingControl.light?.color = selectedColor
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
}

class ColorPickerCell: UICollectionViewCell{
    @IBOutlet weak var colorView: UIView!
    var color: UIColor!{
        didSet{
            colorView.backgroundColor = color
            colorView.clipsToBounds = true
            colorView.layer.cornerRadius = 39.0
        }
    }
}

class ColorPickerCollectionView: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource{
    let colors: [UIColor] = [UIColor.black, UIColor.blue, UIColor.brown, UIColor.cyan, UIColor.purple,UIColor.gray,UIColor.yellow,                    UIColor.darkGray,UIColor.magenta, UIColor().rgb(r: 250, g: 190, b:190), UIColor().rgb(r: 210, g: 245, b:60), UIColor().rgb(r: 230, g: 190, b:255), UIColor().rgb(r: 255, g: 250, b:200), UIColor().rgb(r: 255, g: 215, b:180)]
    var selectedColor: UIColor!
    let hapticGenerator = UIImpactFeedbackGenerator(style: .medium)
    
    @IBOutlet weak var colorsColelctionView: UICollectionView! {
        didSet{
            colorsColelctionView.dataSource = self
            colorsColelctionView.delegate = self
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return colors.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "colorsCell", for: indexPath)
        if let colorCell = cell as? ColorPickerCell{
            colorCell.color = colors[indexPath.row]
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath), let custom = cell as? ColorPickerCell{
            selectedColor = custom.color
            custom.colorView.layer.borderWidth = 5.0
            custom.colorView.layer.borderColor = customGreen().cgColor
            hapticGenerator.impactOccurred()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath), let custom = cell as? ColorPickerCell{
            selectedColor = custom.color
            custom.colorView.layer.borderWidth = 0
            custom.colorView.layer.borderColor = UIColor.clear.cgColor
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let dest = segue.destination as? SceneViewController{
            dest.selectedColor = selectedColor
        }
    }
    
}

