//
//  SceneSettingsTableViewController.swift
//  CSDTModelViewer
//
//  Created by Jing Wei Li on 2/2/18.
//  Copyright © 2018 Jing Wei Li. All rights reserved.
//

import UIKit

class SceneSettingsTableViewController: UITableViewController {
    let allSettings: [[String]] = [["PlaceHolder"],
                                   ["Ambient", "Directional", "Omnidirectional", "Probe", "Spot"],
                                   ["Add","Alpha", "Multiply", "Subtract", "Screen", "Replace"],
                                   ["None", "Rotate"]]
    let sectionTitles: [String] = ["AR Settings","Light Settings", "Blend Mode Settings", "Animation Settings"]
    let impactGenerator = UIImpactFeedbackGenerator(style: .medium)
    
    var lightSettings: String!
    var blendSettings: String!
    var selectedLightSetting: String!
    var selectedBlendSetting: String!
    var selectedAnimationSetting: animationSettings!
    var prevLightIndex: IndexPath!
    var prevBlendIndex: IndexPath!
    var prevAnimationIndex: IndexPath!
    var animationMode: animationSettings!
    var ARModelScale:Float!

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
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ARScale", for: indexPath)
            cell.detailTextLabel?.text = String(ARModelScale)
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "settingsCell", for: indexPath)
        switch indexPath.section{
        case 1:
            if lightSettings == allSettings[indexPath.section][indexPath.row]{
                prevLightIndex = indexPath
                cell.accessoryType = .checkmark
            }
            cell.textLabel?.text = allSettings[indexPath.section][indexPath.row]
        case 2:
            if blendSettings == allSettings[indexPath.section][indexPath.row]{
                prevBlendIndex = indexPath
                cell.accessoryType = .checkmark
            }
            cell.textLabel?.text = allSettings[indexPath.section][indexPath.row]
        case 3:
            let curr = allSettings[indexPath.section][indexPath.row]
            if ((animationMode == animationSettings.none && curr == "None") || (animationMode == .rotate && curr == "Rotate")) {
                prevAnimationIndex = indexPath
                cell.accessoryType = .checkmark
            }
            cell.textLabel?.text = allSettings[indexPath.section][indexPath.row]
        default:break
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionTitles[section]
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section{
        case 0:
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
            prevLightIndex = indexPath
            tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
        case 2:
            tableView.cellForRow(at: prevBlendIndex)?.accessoryType = .none
            selectedBlendSetting = allSettings[indexPath.section][indexPath.row]
            prevBlendIndex = indexPath
            tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
        case 3:
            tableView.cellForRow(at: prevAnimationIndex)?.accessoryType = .none
            switch allSettings[indexPath.section][indexPath.row]{
            case "None":
                selectedAnimationSetting = animationSettings.none
            case "Rotate":
                selectedAnimationSetting = .rotate
            default: break
            }
            prevAnimationIndex = indexPath
            tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
        default:break
        }
        impactGenerator.impactOccurred()
    }

}
