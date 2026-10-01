//
//  UIViewController.swift
//  UIViewController
//
//  Created by invictus on 2016/11/17.
//  Copyright © 2016年 invictus. All rights reserved.
//

import Foundation
import UIKit
 // MARK: - ViewPager Container TitleBar ScrollType
public enum UIViewPagerTitleBarScrollType{
    case UIViewControllerMenuScroll
    case UIViewControllerMenuFixed
}
// MARK: - ViewPager Show Options
public enum UIViewPagerOption {
    case TitleBarHeight(CGFloat)
    case TitleBarBackgroudColor(UIColor)
    case TitleBarScrollType(UIViewPagerTitleBarScrollType)
    case TitleFont(UIFont)
    case TitleColor(UIColor)
    case TitleSelectedColor(UIColor)
    case TitleItemWidth(CGFloat)
    case IndicatorColor(UIColor)
    case IndicatorHeight(CGFloat)
    case BottomlineColor(UIColor)
    case BottomlineHeight(CGFloat)
}

 // MARK: - Scroll view delegate

class InnderScrollViewDelegate:NSObject, UIScrollViewDelegate{
    var startLeft:CGFloat = 0.0
    var startRight:CGFloat = 0.0
    var scrollToLeftEdageFun:(()->())?
    var scrollToRightRightEdageFun:(()->())?
    var scrollToPageFun:((_ page:Int)->())?
    override init() {
        super.init()
    }
    func didScorllToLeftEdage(){
        if let scrollToLeftEdageFun = scrollToLeftEdageFun{
            scrollToLeftEdageFun()
        }
    }
    func didScorllToRightEdage(){
        if let scrollToRightRightEdageFun = scrollToRightRightEdageFun{
            scrollToRightRightEdageFun();
        }
    }
    func onScrollToPage(page:Int){
        if let scrollToPageFun = scrollToPageFun{
            scrollToPageFun(page)
        }
    }
    
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        startLeft = scrollView.contentOffset.x
        startRight = scrollView.contentOffset.x + scrollView.frame.size.width;
    }
    
    public func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        self.onScrollToPage(page:Int(targetContentOffset.pointee.x/scrollView.frame.width))
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let bottomEdge = scrollView.contentOffset.x + scrollView.frame.size.width;
        if (bottomEdge >= scrollView.contentSize.width && bottomEdge == startRight) {
            self.didScorllToLeftEdage()
        }
        if (scrollView.contentOffset.x == 0&&startLeft == 0) {
            self.didScorllToRightEdage()
        }
    }
}
 // MARK: - ViewPager Container
open class ISViewPagerContainer:UIViewController{
    let titles:[String]
    let viewPages:[UIViewController]
    var titleBarHeight:CGFloat = 50.0
    var titleBarBackgroudColor = UIColor.white
    var titleBarScrollType = UIViewPagerTitleBarScrollType.UIViewControllerMenuFixed
    var titleFont = UIFont.systemFont(ofSize: 17)
    var titleItemWidth:CGFloat = 100.0
    var titleColor = UIColor.black
    var titleSelectedColor = UIColor.blue
    var indicatorColor = UIColor.gray
    var indicatorHeight:CGFloat = 8.0
    var bottomlineColor  = UIColor.blue
    var bottomlineHeight:CGFloat = 5.0
    private var titleLables = [UIButton]()
    private let contentView = UIScrollView()
    private let titleBar = UIScrollView()
    private let indicator = UIView();
    private let bottomline = UIView();
    private let scrollDelegate = InnderScrollViewDelegate()
    
    private var curIndex=0
    
   //MARK: - init Function
    public init(titles:[String],viewPages:[UIViewController],options:[UIViewPagerOption]?) {
        self.titles = titles
        self.viewPages = viewPages
        super.init(nibName: nil, bundle: nil)
        self.scrollDelegate.scrollToLeftEdageFun = self.didScorllToLeftEdage
        self.scrollDelegate.scrollToRightRightEdageFun = self.didScorllToRightEdage
        self.scrollDelegate.scrollToPageFun = self.scrollIndicator
        if let options = options {
            for option in options{
                switch (option){
                case  let .TitleBarHeight(value):
                    titleBarHeight = value
                case  let .TitleBarBackgroudColor(value):
                    titleBarBackgroudColor = value
                case let .TitleBarScrollType(value):
                    titleBarScrollType = value
                case  let .TitleFont(value):
                    titleFont = value
                case  let .TitleColor(value):
                    titleColor = value
                case  let .TitleSelectedColor(value):
                    titleSelectedColor = value
                case  let .TitleItemWidth(value):
                    titleItemWidth = value
                case  let .IndicatorColor(value):
                    indicatorColor = value
                case let .IndicatorHeight(value):
                    indicatorHeight = value
                case  let .BottomlineColor(value):
                    bottomlineColor = value
                case let .BottomlineHeight(value):
                    bottomlineHeight = value
                }
            }
        }
    }
   
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        if((UIDevice.current.systemVersion as NSString).doubleValue >= 7.0){
            self.edgesForExtendedLayout = UIRectEdge(rawValue: 0)
        }
        self.setupUI()
    }
    
    
    open override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        self.layoutUIElement(width: size.width,height:size.height)
        self.scrollIndicator(index: curIndex)
        contentView.contentOffset = CGPoint(x:CGFloat(curIndex)*contentView.frame.width, y: contentView.contentOffset.y)
    }
    
    func setupUI() {
        
        switch titleBarScrollType {
        case .UIViewControllerMenuFixed:
            titleItemWidth =  self.view.frame.width/CGFloat(viewPages.count)
        case .UIViewControllerMenuScroll: break
        }
        self.setupUIElement()
        self.layoutUIElement(width: self.view.frame.width,height: self.view.frame.height)
        self.scrollIndicator(index: 0)
    }
    @objc func onClickTitle(_ title:UIControl){
        scrollIndicator(index:title.tag)
        contentView.contentOffset = CGPoint(x:CGFloat(title.tag)*contentView.frame.width, y: contentView.contentOffset.y)
    }
    
    func setupUIElement(){
        
        titleBar.backgroundColor = titleBarBackgroudColor
        titleBar.isPagingEnabled = true;
        titleBar.bounces = false
        titleBar.showsHorizontalScrollIndicator = false;
        
        for i in 0..<titles.count{
            let titleLabel = UIButton()
            titleLabel.titleLabel?.font = titleFont;
            titleLabel.setTitle(titles[i], for: UIControl.State.normal)
            titleLabel.titleLabel?.textAlignment = NSTextAlignment.center
            titleLabel.setTitleColor(titleColor, for: UIControl.State.normal)
            titleLabel.tag = i
            titleLabel.addTarget(self, action:#selector(ISViewPagerContainer.onClickTitle(_:)), for:.touchUpInside)
            titleLables.append(titleLabel)
            titleBar.addSubview(titleLabel)
        }
        bottomline.backgroundColor = bottomlineColor
        titleBar.addSubview(bottomline)
        
        indicator.frame = CGRect(x: 0, y:titleBarHeight-indicatorHeight, width: titleItemWidth, height: indicatorHeight)
        indicator.backgroundColor = indicatorColor
        titleBar.addSubview(indicator)
        
        self.view.addSubview(titleBar)
        
        viewPages.forEach({  contentView.addSubview($0.view) ;self.addChild($0)})
        contentView.delegate = scrollDelegate;
        contentView.isPagingEnabled = true;
        contentView.showsHorizontalScrollIndicator = false;
        self.view.addSubview(contentView)
    }
    
    func layoutUIElement(width:CGFloat, height:CGFloat){
        
        titleBar.frame =  CGRect(x: 0, y:0, width:Int(width), height: Int(titleBarHeight))
        titleBar.contentSize = CGSize(width: titleItemWidth*CGFloat(viewPages.count), height: titleBarHeight)
        
        for i in 0..<titleLables.count{
            let titleLabel = titleLables[i]
            titleLabel.frame =  CGRect(x:CGFloat(i)*titleItemWidth,y:0,width:titleItemWidth,height:titleBarHeight)
        }
        bottomline.frame = CGRect(x: 0, y: titleBarHeight-bottomlineHeight, width: titleBar.contentSize.width, height: bottomlineHeight)
       
        
        contentView.frame = CGRect(x: 0, y: titleBar.frame.origin.y + titleBar.frame.height, width: self.view.frame.width, height: self.view.frame.height - titleBar.frame.origin.y-titleBar.frame.height)
        contentView.contentSize = CGSize(width: CGFloat(viewPages.count)*(contentView.frame.width), height: (contentView.frame.height))
        
        for i in 0..<viewPages.count{
            let viewPage = viewPages[i]
            viewPage.view.frame = CGRect(x: CGFloat(i)*contentView.frame.width, y: 0, width: contentView.frame.width, height: contentView.frame.height)
        }
    }
    
    func scrollIndicator(index:Int){
        let rang = 0..<viewPages.count
        guard rang.contains(index) else {
            return
        }
        self.didScrollToPage(index: UInt(index))
        
        if curIndex>index{
            if indicator.frame.origin.x-titleItemWidth<titleBar.contentOffset.x {
                titleBar.scrollRectToVisible(CGRect(x: CGFloat(index)*self.titleItemWidth, y:0, width:titleBar.frame.width,height:titleBar.frame.height), animated: true)
            }
        }else if curIndex<=index{
            if indicator.frame.origin.x+2*titleItemWidth>titleBar.contentOffset.x + titleBar.frame.width {
                titleBar.scrollRectToVisible(CGRect(x: CGFloat(index)*self.titleItemWidth, y:0, width:titleBar.frame.width,height:titleBar.frame.height), animated: true)
            }
        }
        let curLabel = titleLables[curIndex]
        curLabel.setTitleColor(titleColor, for: UIControl.State.normal)
        curIndex = index;
        let lable = titleLables[curIndex]
        lable.setTitleColor(titleSelectedColor, for: UIControl.State.normal)
        UIView.animate(withDuration: 0.2, animations: { () -> Void in
            self.indicator.frame = CGRect(x: CGFloat(index)*self.titleItemWidth, y:self.titleBarHeight-self.indicatorHeight, width: self.titleItemWidth, height: self.indicatorHeight)
        })
        
    }

    
    // MARK: -  handle event
    public func didScrollToPage(index:UInt){
    }
    public func didScorllToLeftEdage(){
    }
    public func didScorllToRightEdage(){
    }
    
 }

