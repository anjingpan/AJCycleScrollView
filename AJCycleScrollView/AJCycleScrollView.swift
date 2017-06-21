//
//  AJCycleScrollView.swift
//  AJCycleScrollView
//
//  Created by 潘安静 on 2017/6/10.
//  Copyright © 2017年 anjing. All rights reserved.
//

import UIKit

//pageControl 位置枚举
public enum PageControlPosition {
    case center
    case left
    case right
}

//轮播图类型枚举
public enum CycleScrollViewType {
    case onlyImage
    case imageWithText
    case onlyText
}


//点击轮播图闭包
public typealias didSelectItemAtIndexpathClosure = (NSInteger) -> Void

class AJCycleScrollView: UIView {

    
    // MARK: - open 变量
    //轮播图类型
    open var cycleViewType : CycleScrollViewType? = .onlyImage{
        didSet {
            //文本和图片共存时，默认 pageControl在右下角
            if cycleViewType == CycleScrollViewType.imageWithText {
                pageControlPosition = .right
            }
            cycleCollectionView.reloadData()
        }
    }
    
    //是否自动滚动
    open var isAutoScroll : Bool? = true{
        didSet {
            if isAutoScroll == false {
                self.invalidateTimer()
            }
        }
    }
    
    //是否循环滚动
    open var isCirculation : Bool? = true{
        didSet {
            //如果不循环轮播，不用将其自动移动到第二页，因为循环轮播在最前面添加了最后页
            if isCirculation == false {
                cycleCollectionView.contentOffset = CGPoint.init(x: 0, y: 0)
            }
            cycleCollectionView.reloadData()
        }
    }
    
    //滚动方向
    open var scrollDirection : UICollectionViewScrollDirection? = .horizontal{
        didSet {
            cycleCollectionFlowLayout.scrollDirection = scrollDirection!
            if isCirculation == true {
                cycleCollectionView.contentOffset = scrollDirection == UICollectionViewScrollDirection.horizontal ? CGPoint.init(x: self.frame.size.width, y: cycleCollectionView.contentOffset.y) : CGPoint.init(x: cycleCollectionView.contentOffset.x, y: self.frame.size.height)
            }
        }
    }
    
    
    //自动滚动时间间隔
    open var autoScrollTimeInterval : NSInteger = 4 {
        didSet {
            self.invalidateTimer()
            self.setupTimer()
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
    
    //pageControl高度
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
            if isCirculation == true {
                cycleCollectionView.contentOffset = scrollDirection == UICollectionViewScrollDirection.horizontal ? CGPoint.init(x: self.frame.size.width, y: cycleCollectionView.contentOffset.y) : CGPoint.init(x: cycleCollectionView.contentOffset.x, y: self.frame.size.height)
            }
        }
    }
    
    //文本数组
    open var textArray : Array<String> = []{
        didSet{
            cycleCollectionView.reloadData()
            if isCirculation == true {
                cycleCollectionView.contentOffset = scrollDirection == UICollectionViewScrollDirection.horizontal ? CGPoint.init(x: self.frame.size.width, y: cycleCollectionView.contentOffset.y) : CGPoint.init(x: cycleCollectionView.contentOffset.x, y: self.frame.size.height)
            }
        }
    }
    
    //点击轮播闭包属性
    open var didSelectItemAtIndexPath : didSelectItemAtIndexpathClosure?
    

    // MARK: - 私有变量
    //collectionView重用标志符
    let kCycleCollectionViewCell = "cycleCollectionViewCell";
    
    fileprivate var cycleImageArray : Array<UIImage> = []                       //循环轮播的图片数组，将原先图片数组在首尾添加最后一张和第一张图片
    fileprivate var cycleTextArray : Array<String> = []                         //循环轮播文字数组
    fileprivate var cycleCollectionView : UICollectionView!
    fileprivate var cycleCollectionFlowLayout : UICollectionViewFlowLayout!
    fileprivate var pageControl : UIPageControl!
    fileprivate var currentIndexpath : NSInteger = 0                            //当前页
    fileprivate var totalIndexpath : NSInteger = 1                              //总页数，循环轮播为图片数组长度加2
    
    //fileprivate var timer : Timer?
    fileprivate var timer : CADisplayLink?                                      //计时器
    fileprivate var count : NSInteger = 0                                       //通过 count 来协助计时，因为现在每秒调用触发函数
    
    
    // MARK: - InitView
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
            self.setupTimer()
            
        }
        
    }
    
    
    func initPageControl() {
        
        pageControl = UIPageControl.init(frame: CGRect(x: 0, y: self.frame.size.height - pageControlHeight, width: self.frame.size.width, height: pageControlHeight))
        pageControl.backgroundColor = pageControlBackgroundColor
        pageControl.pageIndicatorTintColor = pageControlTintColor
        pageControl.currentPageIndicatorTintColor = pageControlCurrentColor
        
        self.addSubview(pageControl)
        
    }
    
    
    // MARK: - Timer
    func setupTimer() {
//        timer = Timer.scheduledTimer(timeInterval: autoScrollTimeInterval, target: self, selector: #selector(scrollNext), userInfo: nil, repeats: true)
//        RunLoop.main.add(timer!, forMode: .commonModes)
        
        //使用屏幕刷新率计时，原先frameInterval在 iOS10上取消，因此采用新提供的preferredFramesPerSecond 只能做到每秒计时，因此添加 count 来帮助计时
        timer = CADisplayLink.init(target: self, selector: #selector(scrollNext))
        timer?.preferredFramesPerSecond =  1
        timer?.add(to: RunLoop.current, forMode: .defaultRunLoopMode)
    }
    
    func invalidateTimer() {
        timer?.invalidate()
        timer = nil
    }

}


// MARK: - CollectionView Delegate && DataSource
extension AJCycleScrollView : UICollectionViewDelegate,UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if imageArray.count != 0 {
            if isCirculation == true  && cycleImageArray.count != imageArray.count + 2 {
                cycleImageArray = imageArray
                cycleImageArray.append(imageArray.first!)
                cycleImageArray.insert(imageArray.last!, at: 0)
            }
        }
        
        if textArray.count != 0 {
            if isCirculation == true && cycleTextArray.count != textArray.count + 2{
                cycleTextArray = textArray
                cycleTextArray.append(textArray.first!)
                cycleTextArray.insert(textArray.last!, at: 0)
            }
        }
        
        if  cycleViewType == CycleScrollViewType.onlyText{
            totalIndexpath = textArray.count
        }else{
            totalIndexpath = imageArray.count
        }
        pageControl.numberOfPages = totalIndexpath
        
        if isCirculation == true {
            //循环轮播在首尾各加了一张图
            totalIndexpath = totalIndexpath + 2
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
            cell.imageView.image = isCirculation == true ? cycleImageArray[indexPath.row] : imageArray[indexPath.row]
        case CycleScrollViewType.imageWithText :
            cell.type = .imageWithText
            cell.imageView.image = isCirculation == true ? cycleImageArray[indexPath.row] : imageArray[indexPath.row]
            cell.textLabel.text = isCirculation == true ? cycleTextArray[indexPath.row] : textArray[indexPath.row]
            cell.textLabel.frame = CGRect.init(x: cell.textLabel.frame.origin.x, y: cell.textLabel.frame.origin.y, width: self.frame.size.width - pageControl.frame.size.width, height: cell.textLabel.frame.size.height)
            
            //根据文本自适应高度
            self.adjustHeightForLabel(label:cell.textLabel)
            let height = cell.textLabel.frame.size.height
            cell.textView.frame = CGRect(x: cell.textView.frame.origin.x, y: self.frame.size.height - height, width: self.frame.size.width, height: height)
            
        case CycleScrollViewType.onlyText :
            cell.type = .onlyText
            cell.textLabel.text = isCirculation == true ? cycleTextArray[indexPath.row] : textArray[indexPath.row]
        }
        
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if didSelectItemAtIndexPath != nil {
            
            didSelectItemAtIndexPath!(currentIndexpath)
        }
    }
    
    //文本自适应高度
    func adjustHeightForLabel(label: UILabel) {
        label.numberOfLines = 0
        let paragraphStyle : NSMutableParagraphStyle = NSMutableParagraphStyle.init()
        let attributes : NSDictionary = [NSFontAttributeName : textFont, NSMutableParagraphStyle() : paragraphStyle.copy()]
        let rect : CGRect = label.text!.boundingRect(with: CGSize.init(width: self.frame.size.width - pageControl.frame.width, height: self.frame.size.height), options: .usesLineFragmentOrigin, attributes: attributes as? [String : Any], context: nil)
        
        let height = rect.size.height + 2
        label.frame = CGRect(x: label.frame.origin.x, y: self.frame.size.height - height, width: self.frame.size.width - pageControl.frame.size.width, height: height)
    }
    
}

// MARK: - ScrollView Delegate
extension AJCycleScrollView : UIScrollViewDelegate{
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if isAutoScroll == true {
            count = 0
            self.invalidateTimer()
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if isAutoScroll == true {
            count = 0
            self.setupTimer()
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let nextIndexpath = isCirculation == true ? currentIndexpath + 2 : currentIndexpath + 1
        if scrollDirection == UICollectionViewScrollDirection.horizontal {
            
            
            if scrollView.contentOffset.x >= CGFloat(nextIndexpath) * self.frame.size.width {
                currentIndexpath += 1
                
                if isCirculation == true && currentIndexpath == totalIndexpath - 2 {
                    self.currentIndexpath = 0
                    scrollView.contentOffset = CGPoint.init(x: self.frame.size.width, y: scrollView.contentOffset.y)
                }
            }
            
            let lastIndexpath = isCirculation == true ? currentIndexpath : currentIndexpath - 1
            
            if scrollView.contentOffset.x <= CGFloat(lastIndexpath) * self.frame.size.width {
                currentIndexpath -= 1
                
                if isCirculation == true && currentIndexpath == -1 {
                    self.currentIndexpath = totalIndexpath - 3
                    scrollView.contentOffset = CGPoint.init(x: CGFloat(currentIndexpath + 1) * self.frame.size.width, y: scrollView.contentOffset.y)
                }
            }
        }else{
            if scrollView.contentOffset.y >= CGFloat(nextIndexpath) * self.frame.size.height {
                currentIndexpath += 1
                
                if isCirculation == true && currentIndexpath == totalIndexpath - 2 {
                    self.currentIndexpath = 0
                    scrollView.contentOffset = CGPoint.init(x: scrollView.contentOffset.x , y: self.frame.size.height)
                }
            }
            
            let lastIndexpath = isCirculation == true ? currentIndexpath : currentIndexpath - 1
            
            if scrollView.contentOffset.y <= CGFloat(lastIndexpath) * self.frame.size.height {
                currentIndexpath -= 1
                
                if isCirculation == true && currentIndexpath == -1 {
                    self.currentIndexpath = totalIndexpath - 3
                    scrollView.contentOffset = CGPoint.init(x: scrollView.contentOffset.x, y:  CGFloat(currentIndexpath + 1) * self.frame.size.height)
                }
            }
        }
        
        pageControl.currentPage = currentIndexpath
    }
    
    func scrollNext() {
        //count 为了计时所用
        count += 1
        if count >= autoScrollTimeInterval {
            //循环轮播在最前面添加了一张末尾图所以加2
            let nextIndexpath = isCirculation == true ? currentIndexpath + 2 : currentIndexpath + 1
            
            //防止不循环轮播时，在最后一页滚动到空白处
            if isCirculation == false && currentIndexpath >= totalIndexpath - 1{
                return
            }
            
            if scrollDirection == UICollectionViewScrollDirection.horizontal {
                cycleCollectionView.setContentOffset(CGPoint.init(x: CGFloat(nextIndexpath) * self.frame.size.width, y: cycleCollectionView.contentOffset.y), animated: true)
            }else{
                cycleCollectionView.setContentOffset(CGPoint.init(x: cycleCollectionView.contentOffset.x , y: CGFloat(nextIndexpath) * self.frame.size.height), animated: true)
            }
            count = 0
        }
    }
}


