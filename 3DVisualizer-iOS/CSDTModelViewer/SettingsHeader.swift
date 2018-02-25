//
//  SettingsHeader.swift
//  CSDTModelViewer
//
//  Created by Jing Wei Li on 2/24/18.
//  Copyright © 2018 Jing Wei Li. All rights reserved.
//

import UIKit

class SettingsHeader: UIView {
    @IBOutlet private weak var settingsLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        //fatalError("Not implemented")
        commonInit()
    }
    
    func addLabel(with text: String?){
        settingsLabel?.text = text?.uppercased()
        settingsLabel.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        settingsLabel.translatesAutoresizingMaskIntoConstraints = true // enable autolayout
        addSubview(settingsLabel)
    }
    
    func commonInit(){
        Bundle.main.loadNibNamed("SettingsHeaderView", owner: self, options: nil)
        self.backgroundColor = UIColor.groupTableViewBackground
    }

}
