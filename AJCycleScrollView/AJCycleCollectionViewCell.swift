//
//  AJCycleCollectionViewCell.swift
//  AJCycleScrollView
//
//  Created by 潘安静 on 2017/6/11.
//  Copyright © 2017年 anjing. All rights reserved.
//

import UIKit

public enum cycleCollectionCellTye : Int{
    case onlyImage = 1, imageWithText = 2, onlyText = 3
}

class AJCycleCollectionViewCell: UICollectionViewCell {
    
    var type : cycleCollectionCellTye = .onlyImage{
        didSet {
            switch type {
            case .onlyImage:
                textLabel.isHidden = true
                textView.isHidden = true
            case .imageWithText:
                textLabel.isHidden = false
                textView.isHidden = false
            case .onlyText:
                textLabel.isHidden = false
                textView.frame = CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height)
                textLabel.frame = CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height)
                imageView.isHidden = true;
            }
        }
    }
    
    
    var imageView : UIImageView! = UIImageView()
    var textLabel : UILabel! = UILabel()
    var textView : UIView! = UIView()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let textHeight : CGFloat = 20.0;
        
        
        imageView.frame = self.bounds
        imageView.contentMode = .scaleToFill
        self.addSubview(imageView)
        
        textView.frame = CGRect(x: 0, y: self.frame.size.height - textHeight, width: self.frame.size.width, height: textHeight)
        textView.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        self.addSubview(textView)
        
        textLabel.frame = CGRect(x: 0, y: self.frame.size.height - textHeight, width: self.frame.size.width, height: textHeight)
        textLabel.numberOfLines = 0
        textLabel.font = UIFont .systemFont(ofSize: 12.0)
        textLabel.textColor = UIColor.white
        textLabel.backgroundColor = UIColor.clear
        self.addSubview(textLabel)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
