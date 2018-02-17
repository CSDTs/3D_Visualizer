//
//  TwoDModelCollectionViewController.swift
//  CSDTModelViewer
//
//  Created by Jing Wei Li on 2/16/18.
//  Copyright © 2018 Jing Wei Li. All rights reserved.
//

import UIKit
import Alamofire

private let reuseIdentifier = "2DCell"

class TwoDModelCollectionViewCell: UICollectionViewCell{
    @IBOutlet weak var artwork: UIImageView!
    @IBOutlet weak var artworkTitle: UILabel!
    var data: (String, String, String, String) = ("Unknown","Unknown","Unknown", "Unknown") {
        didSet{
            artworkTitle.text = data.0
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                let url = URL(string: (self?.data.2)!)
                if let imageData = try? Data(contentsOf: url!), let image = UIImage(data: imageData){
                    DispatchQueue.main.async {
                        self?.artwork.contentMode = .scaleAspectFill
                        self?.artwork.image = image
                    }
                }
            }
        }
    }
    
}

class TwoDModelCollectionViewController: UICollectionViewController {
    @IBOutlet weak var cellLoadingIndicator: UIActivityIndicatorView!
    //data structure representing the name, description, image link and web url
    var allData: [(String, String, String, String)] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cellLoadingIndicator.startAnimating()
        
        Alamofire.request("https://csdt.rpi.edu/api/application/").responseJSON { response in
            guard let data = response.data else { return }
            let jsonData = try? JSONSerialization.jsonObject(with: data, options: [])
            
            for fetchedData in jsonData as! [Dictionary<String, Any>]{
                var dataEntry: (String, String, String, String)
                    = ("Unknown","Unknown","Unknown", "https://csdt.rpi.edu")
                if let name = fetchedData["name"] as? String{
                    dataEntry.0 = name.capitalized
                }
                if let descrip = fetchedData["description"] as? String{
                    dataEntry.1 = descrip
                }
                if let imageURL = fetchedData["screenshot"] as? String{
                    dataEntry.2 = imageURL
                }
                if let webLink = fetchedData["url"] as? String{
                    dataEntry.3 = dataEntry.3 + webLink
                }
                self.allData.append(dataEntry)
            }
            self.collectionView?.reloadData()
            self.cellLoadingIndicator.stopAnimating()
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupCollectionViewLayout(with: collectionView, andSize: traitCollection.horizontalSizeClass)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        var destination = segue.destination
        if let nav = destination as? UINavigationController{
            destination = nav.visibleViewController ?? destination
        }
        if let dest = destination as? TwoDSpecificsViewController{
            if let indexPath = self.collectionView?.indexPathsForSelectedItems?.first!{
                dest.specificData = allData[indexPath.row]
            }
        }
    }
    

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return allData.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
    
        // Configure the cell
        if let customCell = cell as? TwoDModelCollectionViewCell{
            customCell.data = allData[indexPath.row]
        }
    
        return cell
    }
}
