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
    var IntensityOrTemperature = true
    var isFromWeb = false
    var blobLink: URL? = nil
    var ARPlaneMode: String = "Horizontal"
    
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
        colorSegments.selectedSegmentIndex = -1
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            if (self?.customURL.contains("blob"))!{ // blob files require special handling
                do {
                    let fileURL = URL(string: (self?.customURL)!)!
                    let fileManager = FileManager.default
                    let modelData =  try Data(contentsOf: fileURL)
                    let directory = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
                    let fileName = fileURL.lastPathComponent
                    try modelData.write(to: directory.appendingPathComponent(fileName).appendingPathExtension("stl"))
                    let convertedFileURL = try! fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent(fileName).appendingPathExtension("stl")
                    DispatchQueue.main.async { self?.modelAsset = MDLAsset(url: convertedFileURL)}
                    self?.ARModelScale = 0.002
                    self?.blobLink = convertedFileURL
                } catch {
                    return
                }
            } else if self?.customURL != "None"{
                if !(self?.isFromWeb)! { self?.customURL = "file://" + (self?.customURL ?? "") }
                guard let url = URL(string: (self?.customURL)!) else {
                    fatalError("failed to open model file")
                }
                DispatchQueue.main.async { self?.modelAsset = MDLAsset(url: url) }
            } else {
                let url = Bundle.main.url(forResource: "Models/AnishinaabeArcs", withExtension: "stl")!
                DispatchQueue.main.async { self?.modelAsset = MDLAsset(url: url)}
                self?.ARModelScale = 0.002
            }
        }
        // hides the ar button if Augmented Reality is not supported on the device.
        if !ARWorldTrackingConfiguration.isSupported {
            ARButton.isHidden = true
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // ask the user to save / not save the 3d model on device
        navigationController?.setNavigationBarHidden(true, animated: true)
        if UserDefaults.standard.bool(forKey: "ThirdPartyLaunch"){
            let saveAlert = UIAlertController(title: "Save Model on Device?", message: "If so, enter the name of model in the text field, with no whitespaces. Make sure that the file name ends with extension .stl .", preferredStyle: .alert)
            saveAlert.addTextField { textfield in
                textfield.text = ""
            }
            let dontSaveAction = UIAlertAction(title: "Don't Save", style: .cancel, handler: nil)
            let saveAction = UIAlertAction(title: "Save", style: .default){ _ in
                guard let fileName = saveAlert.textFields![0].text else { return }
                // now save to file system
                let fileManager = FileManager.default
                do {
                    let directory = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
                    let fileURL = directory.appendingPathComponent(fileName)
                    let modelData =  try Data(contentsOf: URL(string: self.customURL)!)
                    try modelData.write(to: fileURL)
                    overlayTextWithVisualEffect(using: "Success", on: self.view)
                } catch {
                    overlayTextWithVisualEffect(using: "\(error)", on: self.view)
                }
            }
            saveAlert.view.tintColor = customGreen()
            saveAlert.addAction(dontSaveAction)
            saveAlert.addAction(saveAction)
            self.present(saveAlert, animated: true, completion: nil)
            UserDefaults.standard.set(false, forKey: "ThirdPartyLaunch")
        }
        NotificationCenter.default.addObserver(forName: NSNotification.Name.UIApplicationWillTerminate, object: UIApplication.shared, queue: OperationQueue.main){ _ in
            if let blobs = self.blobLink { try? FileManager.default.removeItem(at: blobs) }
        }
    }
    
    fileprivate func setUp(){
        if let object = modelAsset.object(at: 0) as? MDLMesh { // valid model object from link
            modelObject = object
        } else { // invalid model, fall back to default model
            let url = Bundle.main.url(forResource: "Models/AnishinaabeArcs", withExtension: "stl")!
            print("Official URL + \(url)")
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
        lightingControl.light?.intensity = 100000
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
        
        sceneView.autoenablesDefaultLighting = true
        sceneView.allowsCameraControl = true
        sceneView.scene = scene
        sceneView.backgroundColor = UIColor.white
        
        wigwaam = scene.rootNode.childNodes.first!
        modelLoadingIndicator?.stopAnimating()
        modelLoadingIndicator?.isOpaque = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if UserDefaults.standard.bool(forKey: "AR3DTouch"){
            ARButton.sendActions(for: .touchUpInside)
        }
        UserDefaults.standard.set(false, forKey: "AR3DTouch")
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
        if IntensityOrTemperature {
            lightingControl.light?.intensity = CGFloat(sender.value)
        } else {
            lightingControl.light?.temperature = CGFloat(sender.value)
        }
    }
    
    @IBAction func changeLightLocation(_ sender: UITapGestureRecognizer) {
        let ctr = sender.location(in: sceneView)
        lightingControl.position = SCNVector3Make(Float(ctr.x), Float(ctr.y), 100)
    }
    
    @IBAction func exitSceneView(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
        if let blobs = blobLink { try? FileManager.default.removeItem(at: blobs) }
    }
    
    @IBAction func updateSceneSettings(from segue:UIStoryboardSegue){
        if let settings = segue.source as? SceneSettingsTableViewController{
            modelNode.geometry?.firstMaterial?.blendMode = stringToBlendMode[settings.selectedBlendSetting]!
            lightingControl.light?.type = stringToLightType[settings.selectedLightSetting]!
            animationMode = settings.selectedAnimationSetting
            ARModelScale = settings.ARModelScale
            ARRotationAxis = settings.ARRotationAxis
            IntensityOrTemperature = settings.IntensityOrTemp
            ARPlaneMode = settings.planeSettings
            if IntensityOrTemperature{
                intensitySlider.maximumValue = 200000
                lightingControl.light?.intensity = CGFloat(intensitySlider.value)
            } else {
                intensitySlider.maximumValue = 2000
                lightingControl.light?.temperature = CGFloat(intensitySlider.value/100)
            }
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
            dest.IntensityOrTemp = IntensityOrTemperature
            dest.planeSettings = ARPlaneMode
        }
        if let dest = destinationViewController as? AugmentedRealityViewController{
            let ar = ARModel()
            ar.model = modelObject
            ar.lightSettings = determineLightType(with: lightingControl.light!)
            ar.blendSettings = determineBlendMode(with: modelNode.geometry!.firstMaterial!.blendMode)
            ar.animationSettings = animationMode
            ar.lightColor = lightingControl.light!.color as! UIColor
            ar.modelScale = ARModelScale
            ar.rotationAxis = ARRotationAxis
            ar.planeDirection = ARPlaneMode
            dest.ar = ar
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
    
    override var previewActionItems: [UIPreviewActionItem]{
        return [UIPreviewAction(title: "View in AR", style: .default) { action, controller in
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: Notification.Name.viewARPeekDidDismiss, object: nil, userInfo: nil)
                UserDefaults.standard.set(self.customURL, forKey: "ARPeek")
                controller.dismiss(animated: true)
            }
        }]
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
    
    override func prepareForReuse() {
        super.prepareForReuse()
        colorView.layer.borderWidth = 0
        colorView.layer.borderColor = UIColor.clear.cgColor
    }
}

class ColorPickerCollectionView: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource{
    let colors: [UIColor] = [UIColor.black, UIColor.blue, UIColor.brown, UIColor.cyan, UIColor.purple,UIColor.gray,UIColor.yellow, UIColor.darkGray,UIColor.magenta, UIColor.rgb(r: 250, g: 190, b:190), UIColor.rgb(r: 210, g: 245, b:60), UIColor.rgb(r: 230, g: 190, b:255), UIColor.rgb(r: 255, g: 250, b:200), UIColor.rgb(r: 255, g: 215, b:180)]
    var selectedColor: UIColor!
    let hapticGenerator = UIImpactFeedbackGenerator(style: .medium)
    var selectedIndexPath: IndexPath?
    
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
            if indexPath == selectedIndexPath {
                colorCell.colorView.layer.borderWidth = 5.0
                colorCell.colorView.layer.borderColor = customGreen().cgColor
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath), let custom = cell as? ColorPickerCell{
            selectedColor = custom.color
            custom.colorView.layer.borderWidth = 5.0
            custom.colorView.layer.borderColor = customGreen().cgColor
            hapticGenerator.impactOccurred()
            selectedIndexPath = indexPath
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath), let custom = cell as? ColorPickerCell{
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

