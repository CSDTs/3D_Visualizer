//
//  TwoDSpecificsViewController.swift
//  CSDTModelViewer
//
//  Created by Jing Wei Li on 2/17/18.
//  Copyright © 2018 Jing Wei Li. All rights reserved.
//

import UIKit
import SceneKit

class TwoDSpecificsViewController: UIViewController {
    @IBOutlet weak var specificsImage: UIImageView!
    @IBOutlet weak var specificsTextView: UITextView!
    @IBOutlet weak var viewARButton: UIButton!
    @IBOutlet weak var imageLoadingIndicator: UIActivityIndicatorView!
    var specificData: (String, String, String, String)!
    var isFullyLoaded = false
    
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
                    self?.isFullyLoaded = true
                    self?.imageLoadingIndicator.stopAnimating()
                }
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func dismissDetails(_ sender: UIBarButtonItem) {
        guard isFullyLoaded else { return }
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func openModelLink(_ sender: UIBarButtonItem) {
        UIApplication.shared.open(URL(string: specificData.3)!, options: [:], completionHandler: nil)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        var destination = segue.destination
        if let nav = destination as? UINavigationController{
            destination = nav.visibleViewController ?? destination
        }
        if let dest = destination as? AugmentedRealityViewController{
            dest.isThreeD = false
            dest.twoDImage = specificsImage.image
            dest.lightSettings = determineLightType(with: SCNLight())
            dest.blendSettings = determineBlendMode(with: SCNBlendMode.alpha)
            dest.animationSettings = animationSettings.none
            dest.lightColor = UIColor.white
            dest.modelScale = 0.002
            dest.rotationAxis = "Y"
        }
    }
    
}
