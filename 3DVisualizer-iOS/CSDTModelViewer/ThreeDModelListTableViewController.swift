//
//  ThreeDModelListTableViewController.swift
//  CSDTModelViewer
//
//  Created by Jing Wei Li on 2/16/18.
//  Copyright © 2018 Jing Wei Li. All rights reserved.
//

import UIKit

class ThreeDModelListTableViewController: UITableViewController {
    var modelNames: [[String]] = [[],[]]
    let sectionTitles = ["Default Models", "Saved Models"]

    lazy var models: [URL] = {
        let modelsURL = Bundle.main.url(forResource: "Models", withExtension: nil)!
        let fileEnumerator = FileManager().enumerator(at: modelsURL, includingPropertiesForKeys: [])!
        return fileEnumerator.compactMap{ element in
            let url = element as! URL
            //guard url.pathExtension == "stl" else { return nil }
            modelNames[0].append(url.lastPathComponent)
            return url
        }
    }()
    
    lazy var savedModels: [URL] = {
        let fileManager = FileManager.default
        var results: [URL] = []
        do {
            let directory = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            let fileEnumerator = FileManager().enumerator(at: directory, includingPropertiesForKeys: [])!
            while let element = fileEnumerator.nextObject() as? URL{
                if (element.lastPathComponent == "Inbox") { continue }
                results.append(element)
                modelNames[1].append(element.lastPathComponent)
            }
        } catch {
            return []
        }
        return results
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        // initialize lazy vars
        let _ = models.count
        let _ = savedModels.count
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return modelNames.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return modelNames[section].count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionTitles[section]
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "3DCell", for: indexPath)
        
        cell.imageView?.image = UIImage(named: "Anishinaabe Arcs")
        cell.imageView?.contentMode = .scaleAspectFit
        cell.textLabel?.text = modelNames[indexPath.section][indexPath.row]
        cell.detailTextLabel?.text = "Design Anishinaabe Arcs in 3D"

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "3DModelListSegue", sender: self)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        var destinationViewController = segue.destination
        if let navigationViewController = destinationViewController as? UINavigationController {
            destinationViewController = navigationViewController.visibleViewController ?? destinationViewController
        }
        if let dest = destinationViewController as? SceneViewController{
            let row = tableView.indexPathForSelectedRow?.row ?? 0
            let section = tableView.indexPathForSelectedRow?.section ?? 0
            if section == 0 {
                dest.customURL = models[row].path
            } else if section == 1{
                dest.customURL = savedModels[row].path
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return indexPath.section == 0 ? false : true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{
            modelNames[indexPath.section].remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            switch indexPath.section{
            case 1:
                let deleted = savedModels.remove(at: indexPath.row)
                try? FileManager().removeItem(at: deleted)
            default: break
            }
        }
    }
 
}
