//
//  SceneSettingsTableViewController.swift
//  CSDTModelViewer
//
//  Created by Jing Wei Li on 2/2/18.
//  Copyright © 2018 Jing Wei Li. All rights reserved.
//

import UIKit

class SceneSettingsTableViewController: UITableViewController {
    let allSettings: [[String]] = [["Ambient", "Directional", "Omnidirectional", "Probe", "Spot"],
                                   ["Add","Alpha", "Multiply", "Subtract", "Screen", "Replace"],
                                   ["None", "Rotate"]]
    let sectionTitles: [String] = ["Light Settings", "Blend Mode Settings", "Animation Settings"]
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
        // #warning Incomplete implementation, return the number of sections
        return sectionTitles.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return allSettings[section].count
    }

    @IBAction func cancelEditing(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "settingsCell", for: indexPath)
        switch indexPath.section{
        case 0:
            if lightSettings == allSettings[indexPath.section][indexPath.row]{
                prevLightIndex = indexPath
                cell.accessoryType = .checkmark
            }
        case 1:
            if blendSettings == allSettings[indexPath.section][indexPath.row]{
                prevBlendIndex = indexPath
                cell.accessoryType = .checkmark
            }
        case 2:
            let curr = allSettings[indexPath.section][indexPath.row]
            if ((animationMode == animationSettings.none && curr == "None") || (animationMode == .rotate && curr == "Rotate")) {
                print("called")
                prevAnimationIndex = indexPath
                cell.accessoryType = .checkmark
            }
        default:break
        }
        cell.textLabel?.text = allSettings[indexPath.section][indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionTitles[section]
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section{
        case 0:
            tableView.cellForRow(at: prevLightIndex)?.accessoryType = .none
            selectedLightSetting = allSettings[indexPath.section][indexPath.row]
            prevLightIndex = indexPath
        case 1:
            tableView.cellForRow(at: prevBlendIndex)?.accessoryType = .none
            selectedBlendSetting = allSettings[indexPath.section][indexPath.row]
            prevBlendIndex = indexPath
        case 2:
            tableView.cellForRow(at: prevAnimationIndex)?.accessoryType = .none
            switch allSettings[indexPath.section][indexPath.row]{
            case "None":
                selectedAnimationSetting = animationSettings.none
            case "Rotate":
                selectedAnimationSetting = .rotate
            default: break
            }
            prevAnimationIndex = indexPath
        default:break
        }
        tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
        impactGenerator.impactOccurred()
    }

}
