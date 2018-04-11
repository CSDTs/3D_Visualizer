//
//  ModelPickerViewController.swift
//  CSDTModelViewer
//
//  Created by Jing Wei Li on 2/2/18.
//  Copyright © 2018 Jing Wei Li. All rights reserved.
//

import UIKit
import Alamofire

class ModelPickerViewController: UIViewController {
    var customURL: String! = "None"
    let defaultURL = "https://github.com/nealrs/CADViewer/raw/gh-pages/models/tsa.stl"
    @IBOutlet weak var customURLButton: UIButton!
    @IBOutlet weak var defaultURLButton: UIButton!
    @IBOutlet weak var listButton: UIButton!
    var isThirdPartyOpen = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        customURLButton.layer.cornerRadius = 30.0
        customURLButton.clipsToBounds = true
        defaultURLButton.layer.cornerRadius = 30.0
        defaultURLButton.clipsToBounds = true
        listButton.layer.cornerRadius = 30.0
        listButton.clipsToBounds = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if UserDefaults.standard.bool(forKey: "ThirdPartyLaunch"){
            isThirdPartyOpen = true
            DispatchQueue.main.async { self.performSegue(withIdentifier: "donePickingModel", sender: self)}
            return
        }
        if UserDefaults.standard.bool(forKey: "OpenLink"){
            customURLButton.sendActions(for: .touchUpInside)
        }
        if UserDefaults.standard.bool(forKey: "OpenDefault"){
            defaultURLButton.sendActions(for: .touchUpInside)
        }
        if UserDefaults.standard.bool(forKey: "OpenList"){
            listButton.sendActions(for: .touchUpInside)
        }
        UserDefaults.standard.set(false, forKey: "OpenLink")
        UserDefaults.standard.set(false, forKey: "OpenDefault")
        UserDefaults.standard.set(false, forKey: "OpenList")
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Navigation
    @IBAction func defaultSegue(_ sender: UIButton) {
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "donePickingModel", sender: self)
        }
    }
    
    @IBAction func customURLSegue(_ sender: UIButton) {
        let alert = UIAlertController(title: "Enter Model URL", message: "Enter a url containing a 3D model", preferredStyle: .alert)
        alert.addTextField{ textField in
            textField.text = self.defaultURL
        }
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
            let textField = alert?.textFields![0] // Force unwrapping because we know it exists.
            self.customURL = textField?.text ?? ""
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "donePickingModel", sender: self)
            }
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.view.tintColor = customGreen()
        self.present(alert, animated: true, completion: nil)
    }
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let dest = segue.destination as? SceneViewController{
            if customURL != "None"{
                dest.isFromWeb = true
                dest.customURL = customURL
            }
            if isThirdPartyOpen{
                dest.customURL = UserDefaults.standard.url(forKey: "OpenedModel")!.path
                isThirdPartyOpen = false
            }
        }
    }

}
