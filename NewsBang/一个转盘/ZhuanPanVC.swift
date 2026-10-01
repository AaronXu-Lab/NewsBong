//
//  ZhuangPanVC.swift
//  NewsBang
//
//  Created by 徐炜楠 on 2018/2/7.

//  Copyright © 2018年 徐炜楠. All rights reserved.
//

import UIKit

class ZhuanPanVC: UIViewController, CAAnimationDelegate {
    
    
    @IBOutlet weak var zhuanpan: UIImageView!
    @IBOutlet weak var btn: UIButton!
    var strPrise = ""
    @IBOutlet weak var labPrise: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //setUI()
        btn.addTarget(self, action: #selector(btnClicked), for: .touchUpInside)
        //self.navigationItem.titleView?.tintColor = UIColor.gray

    
        // Do any additional setup after loading the view.
    }
    func setUI(){
        //背景
        let imgViewBg = UIImageView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height))
        imgViewBg.image = UIImage(named: "餐点主题 背景")
        self.view.addSubview(imgViewBg)
        
        //转盘
        zhuanpan.frame = CGRect(x: 56, y: 123, width: 302, height: 302)
        zhuanpan.image = UIImage(named: "转盘")
        self.view.addSubview(zhuanpan)
        
        //手指
        let hander = UIImageView(frame: CGRect(x: 161, y: 206, width: 94, height: 114))
        hander.center = CGPoint(x: zhuanpan.center.x-10, y: zhuanpan.center.y-30)
        hander.image = UIImage(named: "指针")
        self.view.addSubview(hander)
        
        //奖项Label
        labPrise.frame = CGRect(x: zhuanpan.frame.minX, y: zhuanpan.frame.maxY+50, width: zhuanpan.frame.width, height: 20)
        labPrise.textColor = UIColor.orange
        labPrise.textAlignment = .center
        self.view.addSubview(labPrise)
        
        //开始或停止按钮
        btn.frame = CGRect(x: (self.view.frame.size.width - 200)/2, y: labPrise.frame.maxY+50, width: 200, height: 35)
        btn.addTarget(self, action: #selector(btnClicked), for: .touchUpInside)
        btn.setTitle("开始", for: .normal)
        btn.backgroundColor = UIColor.orange
        btn.layer.borderColor = UIColor.orange.cgColor
        btn.layer.borderWidth = 1
        btn.layer.cornerRadius = 5
        btn.clipsToBounds = true
        self.view.addSubview(btn)
    }
    @objc func btnClicked(){
        var angle = 0
        let randomNum = arc4random()%80
        print("范围:\(randomNum)")
        if randomNum >= 0 && randomNum < 10 {
            angle = 45+720
            self.strPrise = "东园二楼"
        }else if randomNum >= 10 && randomNum < 20 {
            angle = 90+720
            self.strPrise = "东园三楼"
        }else if randomNum >= 20 && randomNum < 30 {
            angle = 135+720
            self.strPrise = "东篱餐吧"
        }else if randomNum >= 30 && randomNum < 40{
            angle = 180+720
            self.strPrise = "韵苑一楼"
        }else if randomNum >= 40 && randomNum < 50{
            angle = 225+720
            self.strPrise = "韵苑二楼"
        }else if randomNum >= 50 && randomNum < 60{
            angle = 270+720
            self.strPrise = "学一食堂"
        }else if randomNum >= 60 && randomNum < 70{
            angle = 315+720
            self.strPrise = "学二食堂"
        }else{
            angle = 360+720
            self.strPrise = "东园一楼"
        }
        //搞个零头
        let 零头 = Int(arc4random()%30) - 15
        angle -= 零头
        btn.setTitle("抽奖中", for: .normal)
        labPrise.text = "等待开奖结果"
        btn.isEnabled = false
        let rotation = CGFloat(Double(angle)*Double.pi/180)
        
        let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotationAnimation.duration = 3
        rotationAnimation.toValue = rotation
        rotationAnimation.isCumulative = true
        rotationAnimation.delegate = self
        rotationAnimation.fillMode = CAMediaTimingFillMode.forwards
        rotationAnimation.isRemovedOnCompletion = false
        zhuanpan.layer.add(rotationAnimation, forKey: "rotationAnimation")
    }
    @IBOutlet weak var dismissBtn: UIButton!
    @IBAction func dismissBtnAction(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    func animationDidStart(_ anim: CAAnimation) {
        print("开始动画")
    }
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        self.labPrise.text = "结果:"+self.strPrise
        self.btn.setTitle("开始抽奖", for: .normal)
        self.btn.isEnabled = true
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

}
