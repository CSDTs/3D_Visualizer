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
                        self?.artwork.layer.borderWidth = 0.375
                        self?.artwork.layer.borderColor = UIColor.darkGray.cgColor
                    }
                }
            }
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.artwork.image = nil
    }
}

class TwoDModelCollectionViewController: UICollectionViewController {
    @IBOutlet weak var cellLoadingIndicator: UIActivityIndicatorView!
    //data structure representing the name, description, image link and web url
    var allData: [(String, String, String, String)] = []
    var isColectionViewLoaded: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cellLoadingIndicator.startAnimating()
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        Alamofire.request("https://csdt.rpi.edu/api/projects/").responseJSON { response in
            guard response.result.isSuccess else {
                let alert = UIAlertController(title: "Network Fetch Failed", message: "Data could not be fetched. Check your internet connection", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default , handler: nil))
                alert.view.tintColor = customGreen()
                self.present(alert, animated: true, completion: nil)
                self.cellLoadingIndicator.stopAnimating()
                return
            }
            guard let data = response.data else { return }
            let jsonData = try? JSONSerialization.jsonObject(with: data, options: [])
            
            for fetchedData in jsonData as! [Dictionary<String, Any>]{
                var dataEntry: (String, String, String, String)
                    = ("Unknown","Unknown","Unknown", "https://csdt.rpi.edu")
                if let id = fetchedData["application"] as? Int {
                    guard id == 38 else { continue }
                }
                if let name = fetchedData["name"] as? String{
                    dataEntry.0 = name.capitalized
                }
                if let descrip = fetchedData["description"] as? String{
                    dataEntry.1 = descrip
                }
                if let imageURL = fetchedData["screenshot_url"] as? String{
                    dataEntry.2 = "https://csdt.rpi.edu" + imageURL
                }
//                if let webLink = fetchedData["url"] as? String{
//                    if webLink.contains("http"){
//                        dataEntry.3 = webLink
//                    } else {
//                        dataEntry.3 += webLink
//                    }
//                }
                dataEntry.3 = "https://csdt.rpi.edu/"
                self.allData.append(dataEntry)
            }
            self.collectionView?.reloadData()
            self.cellLoadingIndicator.stopAnimating()
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard !isColectionViewLoaded else { return }
        setupCollectionViewLayout(with: collectionView, andSize: traitCollection.horizontalSizeClass)
        isColectionViewLoaded = true
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        // adjust cell size when screen rotates
        guard let flowLayout = self.collectionView?.collectionViewLayout as? UICollectionViewFlowLayout else { return }
        let width = size.width//collectionView?.bounds.width ?? UIScreen.main.bounds.width
        let widthFactor: CGFloat = (self.traitCollection.horizontalSizeClass == .compact) ? 2.0 : 3.0
        let heightFactor: CGFloat = (self.traitCollection.horizontalSizeClass == .compact) ? 1.71 : 3.0
        flowLayout.itemSize = CGSize(width: width / widthFactor, height: width / heightFactor)// 2.05 & 1.75
        if size.width < UIScreen.main.bounds.width / 3 {
            flowLayout.itemSize = CGSize(width: size.width, height: size.width)// 2.05 & 1.75
        }
        flowLayout.invalidateLayout()
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
