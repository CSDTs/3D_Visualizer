//
//  MasterListViewController.swift
//  CSDTModelViewer
//
//  Created by Jing Wei Li on 2/16/18.
//  Copyright © 2018 Jing Wei Li. All rights reserved.
//

import UIKit

class MasterListViewController: UIViewController {
    @IBOutlet weak var twoDView: UIView!
    @IBOutlet weak var threeDView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        //twoDView.alpha = 0
        twoDView.isHidden = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func donePickingFromList(_ sender: UIBarButtonItem) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func changeDimensionController(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0: // 3D
            twoDView.isHidden = true
            threeDView.isHidden = false
        case 1: // 2D
            twoDView.isHidden = false
            threeDView.isHidden = true
        default:
            break
        }
    }
}
