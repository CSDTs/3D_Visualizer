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
    var data: (String, String, String, String, String) = ("Unknown","Unknown","Unknown", "Unknown", "Unknown") {
        didSet{
            artworkTitle.text = data.0
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                let url = URL(string: (self?.data.2 ?? "https://csdt.rpi.edu"))
                if let imageData = try? Data(contentsOf: url!), let image = UIImage(data: imageData){
                    DispatchQueue.main.async {
                        UIApplication.shared.isNetworkActivityIndicatorVisible = false
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

class TwoDModelCollectionViewController: UICollectionViewController, UIViewControllerPreviewingDelegate {
    @IBOutlet weak var cellLoadingIndicator: UIActivityIndicatorView!
    //data structure representing the name, description, image link and web url
    var allData: [(String, String, String, String, String)] = []
    var isCollectionViewSetUp = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Server"
        performFetch(withRefresher: nil)
        if #available(iOS 10.0, *){
            let refreshControl = UIRefreshControl()
            refreshControl.attributedTitle = NSAttributedString(string: "PULL TO REFRESH", attributes: [NSAttributedStringKey.font: UIFont(name: "Avenir", size: 13.0) ?? UIFont.boldSystemFont(ofSize: 13.0)])
            refreshControl.addTarget(self, action: #selector(refreshModels(sender:)), for: .valueChanged)
            self.collectionView?.refreshControl = refreshControl
        }
    }
    
    
    @objc private func refreshModels(sender: UIRefreshControl){
        performFetch(withRefresher: sender)
    }
    
    @IBAction func dismiss(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    private func performFetch(withRefresher refresher: UIRefreshControl?){
        cellLoadingIndicator.startAnimating()
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        Alamofire.request("https://csdt.rpi.edu/api/projects/").responseJSON { response in
            guard response.result.isSuccess else {
                let alert = UIAlertController(title: "Network Fetch Failed", message: "Data could not be fetched. Check your internet connection", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default , handler: nil))
                alert.view.tintColor = customGreen()
                self.present(alert, animated: true, completion: nil)
                self.cellLoadingIndicator.stopAnimating()
                refresher?.endRefreshing()
                return
            }
            guard let data = response.data else { return }
            let jsonData = try? JSONSerialization.jsonObject(with: data, options: [])
            self.allData = JSONFetch.fetchFromCSDTServer(with: jsonData)
            self.collectionView?.reloadData()
            self.cellLoadingIndicator.stopAnimating()
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            refresher?.endRefreshing()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if !isCollectionViewSetUp { // DO NOT DELETE: CRUCIAL FOR PREVENTING "OBJECT CAN'T BE NIL" ERROR
            setupCollectionViewLayout(with: collectionView, andSize: traitCollection.horizontalSizeClass)
            isCollectionViewSetUp = true
        }
        if traitCollection.forceTouchCapability == .available{
            registerForPreviewing(with: self, sourceView: collectionView ?? view)
        }
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
    
    // MARK: UIViewControllerPreviewingDelegate (For force touch)
    // peek
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        guard let indexPath = collectionView?.indexPathForItem(at: location) else { return nil }
        guard let cell = collectionView?.cellForItem(at: indexPath) else { return nil }
        guard let peekedVC = storyboard?.instantiateViewController(withIdentifier: "modelDetailNav") as? UINavigationController else {return nil}
        (peekedVC.visibleViewController as? TwoDSpecificsViewController)?.specificData = allData[indexPath.row]
        peekedVC.preferredContentSize = CGSize(width: 0, height: 300.0)
        previewingContext.sourceRect = cell.convert(cell.bounds, to: collectionView)
        return peekedVC
        
    }
    // pop
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        show(viewControllerToCommit, sender: self)
    }
}
