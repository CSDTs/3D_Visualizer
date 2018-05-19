//
//  TwoDSpecificsViewController.swift
//  CSDTModelViewer
//
//  Created by Jing Wei Li on 2/17/18.
//  Copyright © 2018 Jing Wei Li. All rights reserved.
//

import UIKit
import SceneKit
import Alamofire

class TwoDSpecificsViewController: UIViewController, XMLParserDelegate {
    @IBOutlet weak var specificsImage: UIImageView!
    @IBOutlet weak var specificsTextView: UITextView!
    @IBOutlet weak var viewARButton: UIButton!
    @IBOutlet weak var imageLoadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var planeDirButton: UIBarButtonItem!
    var specificData: (String, String, String, String, String)!
    var ARModelLink = ""
    var isHorizontal = true {
        didSet{
            if isHorizontal{
                planeDirButton.image = UIImage(named: "horizontalIcon")
                overlayTextWithVisualEffect(using: "Horizontal AR Plane", on: view)
            } else {
                planeDirButton.image = UIImage(named: "verticalIcon")
                overlayTextWithVisualEffect(using: "Vertical AR Plane", on: view)
            }
        }
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = specificData.0
        
        specificsTextView.text = !specificData.1.isEmpty ? specificData.1 : "Description Coming Soon"
        specificsTextView.isEditable = false
        
        viewARButton.layer.cornerRadius = 15.0
        viewARButton.clipsToBounds = true
        imageLoadingIndicator.startAnimating()
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            let url = URL(string: (self?.specificData.2)!)
            if let imageData = try? Data(contentsOf: url!), let image = UIImage(data: imageData){
                DispatchQueue.main.async {
                    self?.specificsImage.image = image
                    self?.specificsImage.clipsToBounds = true
                    self?.imageLoadingIndicator.stopAnimating()
                }
            }
        }
        
        DispatchQueue.global(qos: .userInteractive).async {
            Alamofire.request(self.specificData.4).response{ response in
                guard response.error == nil else { return }
                if let data = response.data{
                    let parser = XMLParser(data: data)
                    parser.delegate = self
                    guard parser.parse() else { return }
                }
            }
        }
    }
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        if elementName == "STL"{
            let val = attributeDict["href"]
            guard val != "" else { return }
            ARModelLink = "https://csdt.rpi.edu" + (val ?? "")
            viewARButton.setTitle("View in 3D", for: .normal)
            planeDirButton.isEnabled = false
            parser.abortParsing() // no need to continue parsing since we already have what we need
        }
    }
        
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func dismissDetails(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func openModelLink(_ sender: UIBarButtonItem) {
        UIApplication.shared.open(URL(string: specificData.3)!, options: [:], completionHandler: nil)
    }
    
    @IBAction func changePlaneDirection(_ sender: UIBarButtonItem) {
        isHorizontal = !isHorizontal
    }
    @IBAction func modelARSegue(_ sender: UIButton) {
        DispatchQueue.main.async {
            if self.ARModelLink == "" { // 2d segue
                self.performSegue(withIdentifier: "flatImageSegue", sender: self)
            } else { // 3d segue
                self.performSegue(withIdentifier: "stlSegue", sender: self)
            }
        }
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        var destination = segue.destination
        if let nav = destination as? UINavigationController{
            destination = nav.visibleViewController ?? destination
        }
        if let dest = destination as? AugmentedRealityViewController{
            let ar = ARModel()
            ar.isThreeD = false
            ar.twoDImage = specificsImage.image
            ar.lightSettings = determineLightType(with: SCNLight())
            ar.blendSettings = determineBlendMode(with: SCNBlendMode.alpha)
            ar.animationSettings = animationSettings.none
            ar.lightColor = UIColor.white
            ar.modelScale = 0.002
            ar.rotationAxis = "Y"
            ar.planeDirection = isHorizontal ? "Horizontal" : "Vertical"
            dest.ar = ar
        }
        if let dest = destination as? SceneViewController{
            dest.customURL = ARModelLink
        }
    }
    
}
