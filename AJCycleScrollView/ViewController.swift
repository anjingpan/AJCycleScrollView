//
//  ViewController.swift
//  AJCycleScrollView
//
//  Created by 潘安静 on 2017/6/10.
//  Copyright © 2017年 anjing. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let imageArray = [UIImage.init(named: "SchoolHotNews_1")!,UIImage.init(named: "SchoolHotNews_2")!,UIImage.init(named: "SchoolHotNews_3")!,UIImage.init(named: "SchoolHotNews_4")!]
        let imageArray1 = ["https://raw.githubusercontent.com/onevcat/Kingfisher/master/images/logo.png","https://imgsa.baidu.com/baike/s%3D220/sign=04094a837b0e0cf3a4f749f93a47f23d/a044ad345982b2b744f9de5538adcbef76099b39.jpg","https://imgsa.baidu.com/baike/s%3D220/sign=2ee98eef9b58d109c0e3aeb0e159ccd0/a5c27d1ed21b0ef4e86875cfd4c451da80cb3e9b.jpg","https://imgsa.baidu.com/baike/s%3D220/sign=348d0a8a64d9f2d3241123ed99ed8a53/d52a2834349b033b14ccc9b113ce36d3d539bd10.jpg"]
        let textArray = ["ajdhajshdjas","阿斯达克最棒","撒 DJ 卡机最棒","两人都ah 快点哈姜思达黄鳝嘉华大厦四大说大话疏忽阿斯达克圣诞卡还是觉得哈市很棒"]
        
        
        let view : AJCycleScrollView = AJCycleScrollView.init(frame: CGRect.init(x: 0, y: 20, width: UIScreen.main.bounds.size.width, height: 180))
        view.imageArray = imageArray
        view.autoScrollTimeInterval = 2
        view.cycleViewType = CycleScrollViewType.imageWithText
        view.textArray = textArray
        view.isCirculation = false
        
        view.didSelectItemAtIndexPath = {(indexpath : NSInteger) in
            print(indexpath)
        }
        self.view.addSubview(view)
        
        
        let view1 : AJCycleScrollView = AJCycleScrollView.init(frame: CGRect.init(x: 0, y: view.frame.maxY + 20, width: UIScreen.main.bounds.size.width, height: 180))
        view1.imageArray = imageArray1 as Array<NSObject>
        
        self.view.addSubview(view1)
        
        
        let view2 : AJCycleScrollView = AJCycleScrollView.init(frame: CGRect.init(x: 0, y: view1.frame.maxY + 20, width: UIScreen.main.bounds.size.width, height: 180))
        view2.cycleViewType = CycleScrollViewType.onlyText
        view2.textArray = textArray
        view2.textFont = UIFont.systemFont(ofSize: 16)
        view2.scrollDirection = UICollectionViewScrollDirection.vertical
        self.view.addSubview(view2)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

