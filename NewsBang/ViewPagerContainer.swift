//
//  ViewPagerContainer.swift
//  NewsBang
//
//  Created by 徐炜楠 on 2018/1/8.
//  Copyright © 2018年 徐炜楠. All rights reserved.
//

import UIKit

class ViewPagerContainer: UIViewController {
    
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
    //初始化的参数
    var titles:[String] = []
    var viewPages:[UIViewController] = []
    var pagesOptions:[UIViewPagerOption] = []
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
    
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        //fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("viewWillAppear")
        self.navigationController?.navigationBar.isHidden = true
        //initParameters()
    }
    func initParameters(){
        let titles = ["学院要闻","通知公告","教务信息","业界动态"]
        var viewPages = [UIViewController]()
        let collegeNewsVC = self.storyboard?.instantiateViewController(withIdentifier: "CollegeNewsVC") as! CollegeNewsVC
        let announcementsVC = self.storyboard?.instantiateViewController(withIdentifier: "AnnouncementsVC") as! AnnouncementsVC
        let educationalInfoVC = self.storyboard?.instantiateViewController(withIdentifier: "EducationalInfoVC") as! EducationalInfoVC
        let stateVC = self.storyboard?.instantiateViewController(withIdentifier: "StateVC") as! StateVC
        collegeNewsVC.footViewHeight = self.tabBarController?.tabBar.frame.height
        announcementsVC.footViewHeight = self.tabBarController?.tabBar.frame.height
        educationalInfoVC.footViewHeight = self.tabBarController?.tabBar.frame.height
        stateVC.footViewHeight = self.tabBarController?.tabBar.frame.height
        viewPages.append(collegeNewsVC)
        viewPages.append(announcementsVC)
        viewPages.append(educationalInfoVC)
        viewPages.append(stateVC)
        
        let pagesOptions:[UIViewPagerOption] = [
            .TitleBarHeight(40),
            .TitleBarBackgroudColor(UIColor.white),
            .TitleBarScrollType(UIViewPagerTitleBarScrollType.UIViewControllerMenuScroll),
            .TitleFont(UIFont.systemFont(ofSize: 12, weight: UIFont.Weight(rawValue: 2))),
            .TitleColor(#colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)),
            .TitleSelectedColor(#colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)),
            .TitleItemWidth(90),
            .IndicatorColor(#colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)),
            .IndicatorHeight(2),
            .BottomlineColor(#colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)),
            .BottomlineHeight(0)
        ]
        self.titles = titles
        self.viewPages = viewPages
        self.pagesOptions = pagesOptions
        
        
        self.scrollDelegate.scrollToLeftEdageFun = self.didScorllToLeftEdage
        self.scrollDelegate.scrollToRightRightEdageFun = self.didScorllToRightEdage
        self.scrollDelegate.scrollToPageFun = self.scrollIndicator
        for option in pagesOptions{
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
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = true
        initParameters()
        if((UIDevice.current.systemVersion as NSString).doubleValue >= 7.0){
            self.edgesForExtendedLayout = UIRectEdge(rawValue: 0)
        }
        self.setupUI()
        // Do any additional setup after loading the view.
    }
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
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
        
        titleBar.frame =  CGRect(x: 0, y:Int(UIApplication.shared.statusBarFrame.size.height), width:Int(width), height: Int(titleBarHeight))
        titleBar.contentSize = CGSize(width: titleItemWidth*CGFloat(viewPages.count), height: titleBarHeight)
        
        for i in 0..<titleLables.count{
            let titleLabel = titleLables[i]
            titleLabel.frame =  CGRect(x:CGFloat(i)*titleItemWidth,y:0,width:titleItemWidth,height:titleBarHeight)
        }
        //print("titleBarHeight-bottomlineHeight:\(titleBarHeight-bottomlineHeight)\ntitleBar.contentSize.width:\(titleBar.contentSize.width)\nbottomlineHeight:\(bottomlineHeight)")
        bottomline.frame = CGRect(x: 0, y: titleBarHeight-bottomlineHeight, width: UIScreen.main.bounds.width, height: bottomlineHeight)
        
        
        contentView.frame = CGRect(x: 0, y: titleBar.frame.origin.y + titleBar.frame.height, width: self.view.frame.width, height: self.view.frame.height - titleBar.frame.origin.y-titleBar.frame.height)
        contentView.contentSize = CGSize(width: CGFloat(viewPages.count)*(contentView.frame.width), height: (contentView.frame.height))
        
        for i in 0..<viewPages.count{
            let viewPage = viewPages[i]
            viewPage.view.frame = CGRect(x: CGFloat(i)*contentView.frame.width, y: 0, width: contentView.frame.width, height: contentView.frame.height)
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
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
