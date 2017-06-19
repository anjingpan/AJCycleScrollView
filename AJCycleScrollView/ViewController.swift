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
        let textArray = ["ajdhajshdjas","阿斯达克最棒","撒 DJ 卡机最棒","两人都ah 快点哈姜思达黄鳝嘉华大厦四大说大话疏忽阿斯达克圣诞卡还是觉得哈市很棒"]
        
        
        let view : AJCycleScrollView = AJCycleScrollView.init(frame: CGRect.init(x: 0, y: 20, width: UIScreen.main.bounds.size.width, height: 180))
        view.imageArray = imageArray
        view.cycleViewType = CycleScrollViewType.imageWithText
        view.textArray = textArray
        self.view.addSubview(view)
        
        
        let view1 : AJCycleScrollView = AJCycleScrollView.init(frame: CGRect.init(x: 0, y: view.frame.maxY + 20, width: UIScreen.main.bounds.size.width, height: 180))
        view1.imageArray = imageArray
        self.view.addSubview(view1)
        
        
        let view2 : AJCycleScrollView = AJCycleScrollView.init(frame: CGRect.init(x: 0, y: view1.frame.maxY + 20, width: UIScreen.main.bounds.size.width, height: 180))
        view2.cycleViewType = CycleScrollViewType.onlyText
        view2.textArray = textArray
        view2.textFont = UIFont.systemFont(ofSize: 16)
        self.view.addSubview(view2)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

