//
//  PhotoDetailViewController.swift
//  PhotoGrid
//
//  Created by Admin on 12/17/18.
//  Copyright © 2018 Admin. All rights reserved.
//

import UIKit


class PhotoDetailViewController: UICollectionViewController,UICollectionViewDelegateFlowLayout {
    
    var arGrid:[Any] = []
    var indexOfPhoto = 0
    var screenWidth = UIScreen.main.bounds.width
    var screenHeight = UIScreen.main.bounds.height


    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.alpha = 0
        self.collectionView.contentOffset = CGPoint(x: screenWidth * CGFloat(indexOfPhoto) as CGFloat, y: 0)
    
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.tapActionCalled))
        self.collectionView.addGestureRecognizer(tapGesture)
    }
    

    
    // MARK: - UICollection View
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: screenWidth, height: screenHeight)
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arGrid.count
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell:CustomPhotoDetailCell = collectionView.dequeueReusableCell(withReuseIdentifier: "CustomPhotoDetailCell", for: indexPath) as! CustomPhotoDetailCell
        cell.imgView.kf.setImage(with:  URL(string:self.arGrid[indexPath.row] as! String), options: [.transition(.fade(0.5))])
        if cell.imgView.image == nil{
            cell.imgView.image = UIImage(named: "noimage")
        }
        return cell
    }
    
    // MARK: - Action Method
    
    @objc func tapActionCalled (tapGestureRecognizer: UITapGestureRecognizer) {
        
        UIView.animate(withDuration: 0.3, delay: 0, options: .transitionCrossDissolve, animations:{
            if self.navigationController?.navigationBar.alpha == 0 {
                self.navigationController?.navigationBar.alpha = 1
            }else {
                self.navigationController?.navigationBar.alpha = 0
            }
        },completion: nil)
    }
}
