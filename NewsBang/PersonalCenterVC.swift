    //
//  PersonalCenterVC.swift
//  NewsBang
//
//  Created by 徐炜楠 on 2018/1/10.
//  Copyright © 2018年 徐炜楠. All rights reserved.
//

import UIKit
import RealmSwift
import MessageUI

class PersonalCenterVC: UIViewController,MFMailComposeViewControllerDelegate {

    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var personInfo: UIView!
    @IBOutlet weak var collocation: UIView!
    @IBOutlet weak var aboutApp: UIView!
    @IBOutlet weak var feedback: UIView!
    @IBOutlet weak var usernameLb: UILabel!
    @IBOutlet weak var usernumberLb: UILabel!
    @IBOutlet weak var useravatar: UIImageView!
    @IBOutlet weak var functionBtn: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        setInteraction()
        #if DEBUG
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "测试样例", style: .plain, target: self, action: #selector(addDemo))
        #endif
        //从修改页面接受消息
        NotificationCenter.default.addObserver(self, selector: #selector(reload(notification:)), name: NSNotification.Name(rawValue:"reload"), object: nil)
        // Do any additional setup after loading the view.
    }
    #if DEBUG
    @objc private func addDemo() {
        do {
            let realm = try Realm()
            guard realm.object(ofType: LocalArticle.self, forPrimaryKey: "https://example.com/") == nil else { collocationTap(); return }
            let article = LocalArticle(); article.url = "https://example.com/"; article.name = "【测试】本地收藏与笔记"; article.date = "测试数据"; article.isFavorite = true
            let note = LocalNote(); note.url = article.url; note.content = "【测试】这条笔记仅保存在本机。"
            try realm.write { realm.add(article); realm.add(note) }
            collocationTap()
        } catch { showLocalError(error) }
    }
    #endif
    @objc func reload(notification:Notification){
        self.setUI()
    }
    func setUI(){
        avatar.layer.cornerRadius = avatar.frame.width/2
        
        do {
            let realm = try Realm()
            let profile = realm.object(ofType: LocalProfile.self, forPrimaryKey: "local")
            usernameLb.text = profile?.name ?? "本地用户"
            usernumberLb.text = "数据仅保存在本机"
            useravatar.image = profile.flatMap { UIImage(data: $0.avatar) } ?? UIImage(named: "缺省头像")
        } catch { showLocalError(error) }
        functionBtn.setTitle("阅读记录", for: .normal)
        functionBtn.addTarget(self, action: #selector(historyTap), for: .touchUpInside)
    }
    func setInteraction(){
        let personInfoTapGuesture = UITapGestureRecognizer(target: self, action: #selector(personInfoTap))
        personInfoTapGuesture.numberOfTapsRequired = 1
        personInfo.addGestureRecognizer(personInfoTapGuesture)
        let collocationTapGuesture = UITapGestureRecognizer(target: self, action: #selector(collocationTap))
        collocationTapGuesture.numberOfTapsRequired = 1
        collocation.addGestureRecognizer(collocationTapGuesture)
        let aboutAppTapGuesture = UITapGestureRecognizer(target: self, action: #selector(aboutAppTap))
        aboutAppTapGuesture.numberOfTapsRequired = 1
        aboutApp.addGestureRecognizer(aboutAppTapGuesture)
        let feedbackTapGuesture = UITapGestureRecognizer(target: self, action: #selector(feedbackTap))
        feedbackTapGuesture.numberOfTapsRequired = 1
        feedback.addGestureRecognizer(feedbackTapGuesture)
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @objc func personInfoTap(){
        print("personInfoTap")
        let personalInfoModify = self.storyboard?.instantiateViewController(withIdentifier: "PersonalInfoModify") as! PersonalInfoModifyVC
        personalInfoModify.imageAvatar = avatar.image
        personalInfoModify.name = usernameLb.text!
        personalInfoModify.number = usernumberLb.text!
        self.navigationController?.pushViewController(personalInfoModify, animated: true)
    }
    @objc func historyTap() {
        guard let history = storyboard?.instantiateViewController(withIdentifier: "MyCollection") as? MyCollectionVC else { return }
        history.showHistory = true; history.title = "阅读记录"; navigationController?.pushViewController(history, animated: true)
    }
    @objc func collocationTap(){
        print("collocationTap")
        let myCollection = self.storyboard?.instantiateViewController(withIdentifier: "MyCollection") as! MyCollectionVC
        myCollection.footViewHeight = self.tabBarController?.tabBar.frame.height
        myCollection.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(myCollection, animated: true)
    }
    @objc func aboutAppTap(){
        print("aboutAppTap")
    }
    @objc func feedbackTap(){
        print("feedbackTap")
        if MFMailComposeViewController.canSendMail(){
            let mailComposeViewController = configuredMailComposeViewController()
            self.present(mailComposeViewController, animated: true, completion: nil)
        }else{
            self.showSendMailErrorAlert()
        }
        
    }
    func alert(error:String,message:String){
        let alert = UIAlertController(title: error, message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alert.addAction(ok)
        self.present(alert, animated: true, completion: nil)
    }
    //配置发邮件的视窗。
    func configuredMailComposeViewController() -> MFMailComposeViewController {
        
        let mailComposeVC = MFMailComposeViewController()
        mailComposeVC.mailComposeDelegate = self
        
        //获取设备名称
        let deviceName = UIDevice.current.name
        //获取系统版本号
        let systemVersion = UIDevice.current.systemVersion
        //获取设备的型号
        let deviceModel = UIDevice.current.model
        //获取设备唯一标识符
        let deviceUUID = UIDevice.current.identifierForVendor?.uuidString
        
        let infoDic = Bundle.main.infoDictionary
        
        // 获取App的版本号
        let appVersion = infoDic?["CFBundleShortVersionString"]
        // 获取App的build版本
        let appBuildVersion = infoDic?["CFBundleVersion"]
        // 获取App的名称
        let appName = infoDic?["CFBundleDisplayName"]
        
        //设置邮件地址、主题及正文
        mailComposeVC.setToRecipients(["woshixwn@gmail.com"])
        mailComposeVC.setSubject("NewsB应用反馈")
        mailComposeVC.setMessageBody("反馈：\n\n\n设备名称：\(deviceName)\n系统版本号：\(systemVersion)\n设备唯一标识符：\(deviceUUID!)\napp版本号：\(appVersion!)\napp build版本：\(appBuildVersion!)", isHTML: false)
        
        return mailComposeVC
        
    }
    //如果用户未设置邮箱
    func showSendMailErrorAlert() {
        
        let sendMailErrorAlert = UIAlertController(title: "无法发送邮件", message: "您的设备尚未设置邮箱，请在“邮件”应用中设置后再尝试发送。", preferredStyle: .alert)
        sendMailErrorAlert.addAction(UIAlertAction(title: "确定", style: .default) { _ in })
        self.present(sendMailErrorAlert, animated: true){}
        
    }
    //消失
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        
        switch result.rawValue {
        case MFMailComposeResult.cancelled.rawValue:
            print("取消发送")
        case MFMailComposeResult.sent.rawValue:
            print("发送成功")
        default:
            break
        }
        self.dismiss(animated: true, completion: nil)
        
    }
}
