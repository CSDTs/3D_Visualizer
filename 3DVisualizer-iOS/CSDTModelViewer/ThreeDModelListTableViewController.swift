//
//  ThreeDModelListTableViewController.swift
//  CSDTModelViewer
//
//  Created by Jing Wei Li on 2/16/18.
//  Copyright © 2018 Jing Wei Li. All rights reserved.
//

import UIKit

class ThreeDModelListTableViewController: UITableViewController, UIViewControllerPreviewingDelegate {
    
    var modelNames: [[String]] = [[],[]]
    let sectionTitles = ["Default Models", "Saved Models"]
    var selectedARIndexPath: IndexPath?

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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if traitCollection.forceTouchCapability == .available{
            registerForPreviewing(with: self, sourceView: tableView)
        }
        NotificationCenter.default.addObserver(self, selector: #selector(handleARPeekDismiss(with:)), name: Notification.Name.viewARPeekDidDismiss, object: nil)
    }
    
    @objc func handleARPeekDismiss(with notification:NSNotification){
        print("notification received")
        if let _ = UserDefaults.standard.url(forKey: "ARPeek"){
            self.tableView.selectRow(at: self.selectedARIndexPath, animated: false, scrollPosition: .middle)
            UserDefaults.standard.set(true, forKey: "AR3DTouch")
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "3DModelListSegue", sender: self)
            }
            UserDefaults.standard.set(nil, forKey: "ARPeek")
        }
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
            self.selectedARIndexPath = indexPath
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
    
    // MARK: UIViewControllerPreviewingDelegate
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        guard let indexPath = tableView.indexPathForRow(at: location), let cell = tableView.cellForRow(at: indexPath), let threeDVC = storyboard?.instantiateViewController(withIdentifier: "sceneViewController") as? SceneViewController else { return nil }
        if indexPath.section == 0 {
            threeDVC.customURL = models[indexPath.row].path
        } else if indexPath.section == 1{
            threeDVC.customURL = savedModels[indexPath.row].path
        }
        threeDVC.preferredContentSize = CGSize(width: 0, height: 300.0)
        previewingContext.sourceRect = cell.frame
        selectedARIndexPath = indexPath
        return threeDVC
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        viewControllerToCommit.navigationController?.setNavigationBarHidden(true, animated: false)
        show(viewControllerToCommit, sender: self)
    }
 
}
