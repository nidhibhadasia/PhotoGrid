//
//  PhotoGridViewController.swift
//  PhotoGrid
//
//  Created by Admin on 12/17/18.
//  Copyright © 2018 Admin. All rights reserved.
//

import UIKit
import Kingfisher


class PhotoGridViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource,UICollectionViewDelegateFlowLayout, UINavigationControllerDelegate {
    
    var arGrid:[Any] = []
    var totalCount = 0
    var isLoading = true
    
    let screenWidth = UIScreen.main.bounds.width

    @IBOutlet weak var collectionViewGrid: UICollectionView!
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        callPugMeAPI()

        self.title = "Pugs"
        setNeedsStatusBarAppearanceUpdate()
        self.navigationController?.navigationBar.barStyle = .black
        
        let longTouch = UILongPressGestureRecognizer(target: self, action: #selector(self.longTouchActionCalled))
        collectionViewGrid.addGestureRecognizer(longTouch)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.alpha = 1

    }
    
    // MARK: - UICollection View Methods
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arGrid.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell:CustomCell = collectionView.dequeueReusableCell(withReuseIdentifier: "CustomCell", for: indexPath) as! CustomCell
        
        cell.indictorView.startAnimating()
        let url = URL(string:self.arGrid[indexPath.row] as! String)

        cell.imgView.kf.setImage(with: url, placeholder:nil, options: [.transition(.fade(0.3))], progressBlock: nil) { (isfinished) in
            
            cell.indictorView.stopAnimating()
            if cell.imgView.image == nil{
                cell.imgView.image = UIImage(named: "noimage")
                cell.lblNotify.text = "Can't copy"
            }else {
                cell.lblNotify.text = "Copied"
            }
        }
        
        if indexPath.row == totalCount-1{
            isLoading = true
            callPugMeAPI()
        }
        return cell
    }
    
     func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        UIView.animate(withDuration: 0.3) {
            if let cell = collectionView.cellForItem(at: indexPath) as? CustomCell {
                cell.lblNotify.alpha = 1
                cell.imgView.transform = .init(scaleX: 0.90, y: 0.90)
                cell.contentView.backgroundColor = UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1)
            }
        }
    }
    
     func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        UIView.animate(withDuration: 0.3) {
            if let cell = collectionView.cellForItem(at: indexPath) as? CustomCell {
                cell.lblNotify.alpha = 0
                cell.imgView.transform = .identity
                cell.contentView.backgroundColor = .clear
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let photoDetail : PhotoDetailViewController = self.storyboard?.instantiateViewController(withIdentifier: "PhotoDetailViewController") as! PhotoDetailViewController
        photoDetail.arGrid = self.arGrid
        photoDetail.indexOfPhoto = indexPath.row
       
        self.navigationController?.view.alpha = 0
        self.navigationController?.view.transform = CGAffineTransform(scaleX: 0.25, y: 0.25)
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations:{
            self.navigationController?.view.alpha = 1
            self.navigationController?.view.transform = CGAffineTransform(scaleX: 1, y: 1)
            self.navigationController?.pushViewController(photoDetail, animated: false)
        }, completion: nil)
    }
    
    
    // MARK: - UICollectionView Layout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: screenWidth/4.1, height: screenWidth/4.1)
    }
    

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let view = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: "myFooterView", for: indexPath as IndexPath)
        // configure footer view
        return view
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        if self.isLoading {
            self.isLoading = false
            return CGSize(width:screenWidth, height:50.0) //size of your UICollectionReusableView
        } else {
            return CGSize(width: 0, height: 0)
        }
    }
   
    // MARK: - Action Method
    
    @objc func longTouchActionCalled(longPressGestureRecognizer: UILongPressGestureRecognizer) {
        
        if longPressGestureRecognizer.state == UIGestureRecognizer.State.began {
            let touchPoint = longPressGestureRecognizer.location(in:collectionViewGrid)
            if let indexPath = collectionViewGrid.indexPathForItem(at: touchPoint){
                let cell:CustomCell = collectionViewGrid.cellForItem(at: indexPath) as! CustomCell
                if cell.imgView.image != UIImage(named: "noimage"){
                    UIPasteboard.general.image = cell.imgView.image
                }
            }
        }
    }
    
    
    // MARK: -  API Call
    
    func callPugMeAPI(){
       
        if self.isLoading {
            let url = NSURL(string:"https://pugme.herokuapp.com/bomb?count=50")
            URLSession.shared.dataTask(with: (url as URL?)!, completionHandler: {(data, response, error) -> Void in
                
                if let jsonObj = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? NSDictionary {
                    
                    if let arPhotos = jsonObj!.value(forKey: "pugs") as? NSArray {
                        self.arGrid += arPhotos
                    }
                    self.totalCount = self.arGrid.count
                    DispatchQueue.main.async {
                        self.collectionViewGrid.reloadData()
                    }
                }
            }).resume()
        }
    }
}

