//
//  SceneSettingsTableViewController.swift
//  CSDTModelViewer
//
//  Created by Jing Wei Li on 2/2/18.
//  Copyright © 2018 Jing Wei Li. All rights reserved.
//

import UIKit

class SceneSettingsTableViewController: UITableViewController {
    let allSettings: [[String]] = [["AR Model Scale", "Rotation Axis"],
                                   ["Ambient", "Directional", "Omnidirectional", "Probe", "Spot"],
                                   ["On: Intensity, Off: Temperature"],
                                   ["Add","Alpha", "Multiply", "Subtract", "Screen", "Replace"],
                                   ["None", "Rotate"],
                                   ["Horizontal", "Vertical"]]
    let sectionTitles: [String] = ["AR Settings","Light Settings",
                                   "Sliding Slider Changes The ... of Light","Blend Mode Settings", "Animation Settings",
                                   "AR Plane Detection Direction"]
    let impactGenerator = UIImpactFeedbackGenerator(style: .medium)
    
    var lightSettings: String!
    var blendSettings: String!
    var planeSettings: String!
    var selectedLightSetting: String!
    var selectedBlendSetting: String!
    var selectedAnimationSetting: animationSettings!
    var prevLightIndex: IndexPath!
    var prevBlendIndex: IndexPath!
    var prevPlaneIndex: IndexPath!
    var prevAnimationIndex: IndexPath!
    var animationMode: animationSettings!
    var ARModelScale:Float!
    var ARRotationAxis: String!
    var IntensityOrTemp = true

    override func viewDidLoad() {
        super.viewDidLoad()
        selectedLightSetting = lightSettings
        selectedBlendSetting = blendSettings
        selectedAnimationSetting = animationMode
        navigationController?.navigationBar.prefersLargeTitles = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return sectionTitles.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allSettings[section].count
    }

    @IBAction func cancelEditing(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 && indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ARScale", for: indexPath)
            cell.textLabel?.text = allSettings[indexPath.section][indexPath.row]
            cell.detailTextLabel?.text = String(ARModelScale)
            return cell
        }
        if indexPath.section == 0 && indexPath.row == 1{
            let cell = tableView.dequeueReusableCell(withIdentifier: "settingsPickerCell", for: indexPath)
            if let pickerCell = cell as? SettingsPickerTableViewCell{
                pickerCell.dataSource = ["X","Y","Z"]
                pickerCell.selectedSetting = ARRotationAxis
            }
            return cell
        }
        if indexPath.section == 2{
            let cell = tableView.dequeueReusableCell(withIdentifier: "switchCell", for: indexPath)
            if let switchedCell = cell as? SwitchTableViewCell{
                switchedCell.switchStatus = IntensityOrTemp
                switchedCell.descriptor = allSettings[indexPath.section][indexPath.row]
            }
            return cell
        }
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "settingsCell", for: indexPath) as? BasicCell
            else { return tableView.dequeueReusableCell(withIdentifier: "settingsCell", for: indexPath) }
        switch indexPath.section{
        case 1:
            if lightSettings == allSettings[indexPath.section][indexPath.row]{
                prevLightIndex = indexPath
                cell.accessoryType = .checkmark
                cell.tintColor = customGreen()
            }
            cell.textLabel?.text = allSettings[indexPath.section][indexPath.row]
        case 3:
            if blendSettings == allSettings[indexPath.section][indexPath.row]{
                prevBlendIndex = indexPath
                cell.accessoryType = .checkmark
                cell.tintColor = customGreen()
            }
            cell.textLabel?.text = allSettings[indexPath.section][indexPath.row]
        case 4:
            let curr = allSettings[indexPath.section][indexPath.row]
            if ((animationMode == animationSettings.none && curr == "None") || (animationMode == .rotate && curr == "Rotate")) {
                prevAnimationIndex = indexPath
                cell.accessoryType = .checkmark
                cell.tintColor = customGreen()
            }
            cell.textLabel?.text = allSettings[indexPath.section][indexPath.row]
        case 5:
            if planeSettings == allSettings[indexPath.section][indexPath.row]{
                cell.accessoryType = .checkmark
                cell.tintColor = customGreen()
                prevPlaneIndex = indexPath
            }
            cell.textLabel?.text = allSettings[indexPath.section][indexPath.row]
        default:break
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section{
        case 0:
            guard indexPath.row == 0 else {return}
            let alert = UIAlertController(title: "Enter AR Model Scale", message: nil, preferredStyle: .alert)
            alert.addTextField{ textField in
                textField.text = String(self.ARModelScale)
            }
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
                let textField = alert?.textFields![0]
                self.ARModelScale = Float(textField?.text ?? "0.07") ?? 0.07
                self.tableView.cellForRow(at: indexPath)?.detailTextLabel?.text = textField?.text ?? "0.07"
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            alert.view.tintColor = customGreen()
            self.present(alert, animated: true, completion: nil)
        case 1:
            tableView.cellForRow(at: prevLightIndex)?.accessoryType = .none
            selectedLightSetting = allSettings[indexPath.section][indexPath.row]
            lightSettings = allSettings[indexPath.section][indexPath.row]
            prevLightIndex = indexPath
            tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
        case 3:
            tableView.cellForRow(at: prevBlendIndex)?.accessoryType = .none
            selectedBlendSetting = allSettings[indexPath.section][indexPath.row]
            blendSettings = allSettings[indexPath.section][indexPath.row]
            prevBlendIndex = indexPath
            tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
        case 4:
            tableView.cellForRow(at: prevAnimationIndex)?.accessoryType = .none
            switch allSettings[indexPath.section][indexPath.row]{
                case "None":
                    selectedAnimationSetting = animationSettings.none
                case "Rotate":
                    selectedAnimationSetting = .rotate
                default: break
            }
            animationMode = selectedAnimationSetting
            prevAnimationIndex = indexPath
            tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
        case 5:
            tableView.cellForRow(at: prevPlaneIndex)?.accessoryType = .none
            planeSettings = allSettings[indexPath.section][indexPath.row]
            prevPlaneIndex = indexPath
            tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
        default:break
        }
        if indexPath.section != 0 {tableView.cellForRow(at: indexPath)?.tintColor = customGreen() }
        impactGenerator.impactOccurred()
    }
    
    
    // prepare for unwind segue back to scenekit view - get the value from picker
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let _ = segue.destination as? SceneViewController{
            let rotationAxisPickerIndex = IndexPath(row: 1, section: 0)
            ARRotationAxis = (tableView.cellForRow(at: rotationAxisPickerIndex) as? SettingsPickerTableViewCell)?.selectedSetting ?? "X"
            let lightIndex = IndexPath(row: 0, section: 2)
            IntensityOrTemp = ((tableView.cellForRow(at: lightIndex)) as? SwitchTableViewCell)?.switchStatus ?? IntensityOrTemp
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let width = tableView.bounds.width
        let frame = CGRect(x: 0, y: 0, width: width, height: 50.0)
        let header = SettingsHeader(frame: frame)
        header.addLabel(with: sectionTitles[section])
        return header
    }
    
//    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        return sectionTitles[section]
//    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50.0
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        // aka the picker
        if indexPath.row == 1 && indexPath.section == 0 {
            return 137.0
        }
        return UITableViewAutomaticDimension
    }
}

class SwitchTableViewCell: UITableViewCell{
    @IBOutlet weak var switchLabel: UILabel!
    @IBOutlet weak var switchControl: UISwitch!
    var switchStatus: Bool!
    var descriptor: String!{
        didSet{
            switchLabel.text = descriptor
            if switchStatus {
                switchControl.isOn = true
            } else {
                switchControl.isOn = false
            }
        }
    }
    
    @IBAction func switchTriggered(_ sender: UISwitch) {
        switchStatus = sender.isOn
    }
}

class BasicCell: UITableViewCell{
    override func prepareForReuse() {
        self.accessoryType = .none
    }
}

