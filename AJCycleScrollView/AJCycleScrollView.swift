//
//  AJCycleScrollView.swift
//  AJCycleScrollView
//
//  Created by 潘安静 on 2017/6/10.
//  Copyright © 2017年 anjing. All rights reserved.
//

import UIKit

public enum PageControlPosition {
    case center
    case left
    case right
}

public enum CycleScrollViewType {
    case onlyImage
    case imageWithText
    case onlyText
}


//点击轮播图闭包
public typealias didSelectItemAtIndexpathClosure = (NSInteger) -> Void

class AJCycleScrollView: UIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    //轮播图类型
    open var cycleViewType : CycleScrollViewType? = .onlyImage{
        didSet {
            if cycleViewType == CycleScrollViewType.imageWithText {
                pageControlPosition = .right
            }
            cycleCollectionView.reloadData()
        }
    }
    
    //是否自动滚动
    open var isAutoScroll : Bool? = true{
        didSet {
            timer?.invalidate()
            timer = nil
        }
    }
    
    //是否循环滚动
    open var isCirculation : Bool? = true{
        didSet {
            cycleCollectionView.reloadData()
        }
    }
    
    //滚动方向
    open var scrollDirection : UICollectionViewScrollDirection? = .horizontal{
        didSet {
            
        }
    }
    
    
    //自动滚动时间间隔
    open var autoScrollTimeInterval : Double = 3.0 {
        didSet {
            timer?.invalidate()
            timer = nil
            timer = Timer.scheduledTimer(timeInterval: autoScrollTimeInterval, target: self, selector: #selector(scrollNext), userInfo: nil, repeats: true)
            RunLoop.main.add(timer!, forMode: .commonModes)
        }
    }
    
    //pageControl 颜色
    open var pageControlTintColor : UIColor? = .black{
        didSet {
            pageControl.pageIndicatorTintColor = pageControlTintColor
        }
    }
    
    //pageControl 当前页数颜色
    open var pageControlCurrentColor : UIColor? = .white{
        didSet{
            pageControl.currentPageIndicatorTintColor = pageControlCurrentColor
        }
    }
    
    //pageControl 背景颜色
    open var pageControlBackgroundColor : UIColor? = .clear{
        didSet{
            pageControl.backgroundColor = pageControlBackgroundColor
        }
    }
    
    //pageControl 位置
    open var pageControlPosition : PageControlPosition = .center{
        didSet {
            switch pageControlPosition {
            case .center:
                pageControl.frame = CGRect(x: 0, y: self.frame.size.height - pageControlHeight, width: self.frame.size.width, height: pageControlHeight)
            case .left:
                pageControl.frame = CGRect(x: 0, y: self.frame.size.height - pageControlHeight, width: self.frame.size.width * 0.4, height: pageControlHeight)
            case .right:
                pageControl.frame = CGRect(x: self.frame.size.width * 0.6, y: self.frame.size.height - pageControlHeight, width: self.frame.size.width * 0.4, height: pageControlHeight)
            }
        }
    }
    
    open var pageControlHeight : CGFloat = 20 {
        didSet {
            switch pageControlPosition {
            case .center:
                pageControl.frame = CGRect(x: 0, y: self.frame.size.height - pageControlHeight, width: self.frame.size.width, height: pageControlHeight)
            case .left:
                pageControl.frame = CGRect(x: 0, y: self.frame.size.height - pageControlHeight, width: self.frame.size.width * 0.4, height: pageControlHeight)
            case .right:
                pageControl.frame = CGRect(x: self.frame.size.width * 0.6, y: self.frame.size.height - pageControlHeight, width: self.frame.size.width * 0.4, height: pageControlHeight)
            }

        }
    }
    
    //文本字体颜色
    open var textColor : UIColor = .white
    
    //文本字体
    open var textFont : UIFont = .systemFont(ofSize: 12.0)
    
    //文本区域背景颜色
    open var textBackgroundColor : UIColor = UIColor.black.withAlphaComponent(0.4)
    
    //图片数组
    open var imageArray : Array<UIImage> = []{
        didSet {
            cycleCollectionView.reloadData()
        }
    }
    
    //文本数组
    open var textArray : Array<String> = []{
        didSet{
            cycleCollectionView.reloadData()
        }
    }
    
    //点击轮播闭包属性
    open var didSelectItemAtIndexPath : didSelectItemAtIndexpathClosure?
    
    let kCycleCollectionViewCell = "cycleCollectionViewCell";
    
    fileprivate var cycleCollectionView : UICollectionView!
    fileprivate var cycleCollectionFlowLayout : UICollectionViewFlowLayout!
    fileprivate var pageControl : UIPageControl!
    fileprivate var currentIndexpath : NSInteger = 0
    fileprivate var totalIndexpath : NSInteger = 1
    
    fileprivate var timer : Timer?
    
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.initCollectionView()
        self.initPageControl()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initCollectionView() {
        cycleCollectionFlowLayout = UICollectionViewFlowLayout.init();
        cycleCollectionFlowLayout.minimumLineSpacing = 0;
        cycleCollectionFlowLayout.itemSize = CGSize.init(width: self.frame.size.width, height: self.frame.size.height)
        cycleCollectionFlowLayout.scrollDirection = scrollDirection!;
        
        cycleCollectionView = UICollectionView.init(frame: self.bounds, collectionViewLayout: self.cycleCollectionFlowLayout)
        cycleCollectionView.backgroundColor = .white
        cycleCollectionView.register(AJCycleCollectionViewCell.self, forCellWithReuseIdentifier: kCycleCollectionViewCell)
        cycleCollectionView.isPagingEnabled = true
        cycleCollectionView.showsVerticalScrollIndicator = false
        cycleCollectionView.showsHorizontalScrollIndicator = false
        cycleCollectionView.delegate = self
        cycleCollectionView.dataSource = self
        self.addSubview(cycleCollectionView)
        
        if isAutoScroll == true {
            timer = Timer.scheduledTimer(timeInterval: autoScrollTimeInterval, target: self, selector: #selector(scrollNext), userInfo: nil, repeats: true)
            RunLoop.main.add(timer!, forMode: .commonModes)
        }
        
    }
    
    
    func initPageControl() {
        
        pageControl = UIPageControl.init(frame: CGRect(x: 0, y: self.frame.size.height - pageControlHeight, width: self.frame.size.width, height: pageControlHeight))
        pageControl.backgroundColor = pageControlBackgroundColor
        pageControl.pageIndicatorTintColor = pageControlTintColor
        pageControl.currentPageIndicatorTintColor = pageControlCurrentColor
        
        self.addSubview(pageControl)
        
    }
    

}

extension AJCycleScrollView : UICollectionViewDelegate,UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if  cycleViewType == CycleScrollViewType.onlyText{
            totalIndexpath = textArray.count
        }else{
            totalIndexpath = imageArray.count
        }
        pageControl.numberOfPages = totalIndexpath
        
        if isCirculation == true {
            totalIndexpath = totalIndexpath * 100
        }
        
        return totalIndexpath
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell : AJCycleCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: kCycleCollectionViewCell, for: indexPath) as! AJCycleCollectionViewCell
        
        cell.textLabel.font = textFont
        cell.textLabel.textColor = textColor
        cell.textView.backgroundColor = textBackgroundColor
        
        switch cycleViewType! {
        case CycleScrollViewType.onlyImage :
            cell.type = .onlyImage
            cell.imageView.image = imageArray[indexPath.row % imageArray.count]
        case CycleScrollViewType.imageWithText :
            cell.type = .imageWithText
            cell.imageView.image = imageArray[indexPath.row % imageArray.count]
            cell.textLabel.text = textArray[indexPath.row % textArray.count]
            cell.textLabel.frame = CGRect.init(x: cell.textLabel.frame.origin.x, y: cell.textLabel.frame.origin.y, width: self.frame.size.width - pageControl.frame.size.width, height: cell.textLabel.frame.size.height)
            
            //根据文本自适应高度
            self.adjustHeightForLabel(label:cell.textLabel)
            let height = cell.textLabel.frame.size.height
            cell.textView.frame = CGRect(x: cell.textView.frame.origin.x, y: self.frame.size.height - height, width: self.frame.size.width, height: height)
            
        case CycleScrollViewType.onlyText :
            cell.type = .onlyText
            cell.textLabel.text = textArray[indexPath.row % textArray.count]
        }
        
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if didSelectItemAtIndexPath != nil {
            
            //循环轮播
            if isCirculation == true {
                didSelectItemAtIndexPath!(currentIndexpath % (totalIndexpath / 100))
            }
            
            didSelectItemAtIndexPath!(currentIndexpath)
        }
    }
    
    func adjustHeightForLabel(label: UILabel) {
        label.numberOfLines = 0
        let paragraphStyle : NSMutableParagraphStyle = NSMutableParagraphStyle.init()
        let attributes : NSDictionary = [NSFontAttributeName : textFont, NSMutableParagraphStyle() : paragraphStyle.copy()]
        let rect : CGRect = label.text!.boundingRect(with: CGSize.init(width: self.frame.size.width - pageControl.frame.width, height: self.frame.size.height), options: .usesLineFragmentOrigin, attributes: attributes as? [String : Any], context: nil)
        
        let height = rect.size.height + 2
        label.frame = CGRect(x: label.frame.origin.x, y: self.frame.size.height - height, width: self.frame.size.width - pageControl.frame.size.width, height: height)
    }
    
}


extension AJCycleScrollView : UIScrollViewDelegate{
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if isAutoScroll == true {
            timer?.invalidate()
            timer = nil
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if isAutoScroll == true {
            timer = Timer.scheduledTimer(timeInterval: autoScrollTimeInterval, target: self, selector: #selector(scrollNext), userInfo: nil, repeats: true)
            RunLoop.main.add(timer!, forMode: .commonModes)
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollDirection == UICollectionViewScrollDirection.horizontal {
            if scrollView.contentOffset.x >= CGFloat(currentIndexpath + 1) * self.frame.size.width {
                currentIndexpath = currentIndexpath + 1
            }
            if scrollView.contentOffset.x <= CGFloat(currentIndexpath - 1) * self.frame.size.width {
                currentIndexpath = currentIndexpath - 1
            }
        }else{
            if scrollView.contentOffset.y >= CGFloat(currentIndexpath + 1) * self.frame.size.height {
                currentIndexpath = currentIndexpath + 1
            }
            if scrollView.contentOffset.x <= CGFloat(currentIndexpath - 1) * self.frame.size.height {
                currentIndexpath = currentIndexpath - 1
            }
        }
        
        if isCirculation == true {
            pageControl.currentPage = currentIndexpath % (totalIndexpath / 100)
        }else{
            pageControl.currentPage = currentIndexpath
        }
    }
    
    func scrollNext() {
        currentIndexpath = currentIndexpath + 1
        
        if scrollDirection == UICollectionViewScrollDirection.horizontal {
            cycleCollectionView.setContentOffset(CGPoint.init(x: CGFloat(currentIndexpath) * self.frame.size.width, y: cycleCollectionView.contentOffset.y), animated: true)
        }else{
            cycleCollectionView.setContentOffset(CGPoint.init(x: cycleCollectionView.contentOffset.x , y: CGFloat(currentIndexpath) * self.frame.size.width), animated: true)
        }
    }
}


