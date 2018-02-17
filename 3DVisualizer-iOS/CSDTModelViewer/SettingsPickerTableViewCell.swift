//
//  SettingsPickerTableViewCell.swift
//  CSDTModelViewer
//
//  Created by Jing Wei Li on 2/11/18.
//  Copyright © 2018 Jing Wei Li. All rights reserved.
//

import UIKit

class SettingsPickerTableViewCell: UITableViewCell, UIPickerViewDelegate, UIPickerViewDataSource {
    var dataSource: [String]! = ["X","Y","Z"] // defaulting to x y z
    var selectedSetting: String!
    @IBOutlet weak var pickerTitle: UILabel!
    @IBOutlet weak var pickerView: UIPickerView!
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return dataSource.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return dataSource[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedSetting = dataSource[row]
    }

    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        pickerView.subviews[row].backgroundColor = UIColor.white
        return NSAttributedString(string: dataSource[row], attributes: [NSAttributedStringKey.foregroundColor: UIColor.black])
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        pickerView.showsSelectionIndicator = true
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        pickerView.delegate = self
        pickerView.dataSource = self
        pickerView.selectRow(0, inComponent: 0, animated: true)
    }

}
