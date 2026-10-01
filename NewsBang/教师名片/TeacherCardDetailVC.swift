//
//  TeacherCardDetailVC.swift
//  NewsBang
//
//  Created by 徐炜楠 on 2018/1/15.
//  Copyright © 2018年 徐炜楠. All rights reserved.
//

import UIKit
import WebKit
import Ji
import RealmSwift

class TeacherCardDetailVC: UIViewController,WKNavigationDelegate {

    @IBOutlet weak var avatarImg: UIImageView!
    @IBOutlet weak var nameLb: UILabel!
    @IBOutlet weak var titleLb: UILabel!
    @IBOutlet weak var contactLb: UILabel!
    @IBOutlet weak var webView: UIView!
    private let browser = WKWebView()
    
    var avatar:UIImage!
    var name:String!
    var contact:String!
    var url:URL!
    var webString = ""
    var cellPosition = ""
    @IBOutlet weak var webViewHeight: NSLayoutConstraint!
    override func viewDidLoad() {
        super.viewDidLoad()
        initParameters()
        setUI()
        // Do any additional setup after loading the view.
    }
    func initParameters(){
        //初始化title
        let titleQuery = LocalQuery(className: "TeacherTitleContact")
        titleQuery.whereKey("name", equalTo: name)
        titleQuery.whereKey("url", equalTo: String.init(describing: url!))
        titleQuery.findObjectsInBackground { (objects:[Any]?, error:Error?) in
            if error == nil{
                for object in objects!{
                    let tempTitle = (object as AnyObject).value(forKey: "title") as! String
                    self.titleLb.text = tempTitle
                }
            }else{
                print("初始化title错误\(error?.localizedDescription)")
            }
        }
        //初始化联系方式
        let contactQuery = LocalQuery(className: "TeacherTitleContact")
        contactQuery.whereKey("name", equalTo: name)
        contactQuery.whereKey("url", equalTo: String.init(describing: url!))
        contactQuery.findObjectsInBackground { (objects:[Any]?, error:Error?) in
            if error == nil{
                for object in objects!{
                    let tempContact = (object as AnyObject).value(forKey: "contact") as! String
                    self.contactLb.text = tempContact
                }
            }else{
                print("初始化contact错误\(error?.localizedDescription)")
            }
        }
        //初始化webString
        let jiDoc = Ji(htmlURL: url)
        var adjustUrl = ""
        if let contentNode = jiDoc?.xPath("//*[@id=\"vsb_content\"]/div")?.first {
            adjustUrl = String(describing: contentNode)
            /*/联系方式，官网格式太复杂不搞了，用自己的数据库
            var contactNode = contentNode.previousSibling?.childrenWithName("p")
            if contactNode?.count == 2{
                print("1、contactNode:\n\(contactNode![0].content!)\n\(contactNode![1].content!)")
                uploadPerson(node: contactNode!, name: name, url: url, position: cellPosition)
            }else{
                for _ in 1...((contactNode?.count)!-2){
                    contactNode?.removeLast()
                }
                print("4、contactNode:\n\(contactNode![0].content!)\n\(contactNode![1].content!)")
                uploadPerson(node: contactNode!, name: name, url: url, position: cellPosition)
            }*/
        }else if let contentNode = jiDoc?.xPath("//body/div[1]/div[4]/div[1]/div/div[2]/form/div")?.first{
            adjustUrl = String(describing: contentNode)
            /*/联系方式，官网格式太复杂不搞了，用自己的数据库
            var contactNode = contentNode.previousSibling?.childrenWithName("p")
            if contactNode?.count != 0 {
                print("2、contactNode:\n\(contactNode![0].content!)\n\(contactNode![1].content!)")
                uploadPerson(node: contactNode!, name: name, url: url, position: cellPosition)
            }else{
                contactNode = contentNode.childrenWithName("ul").first?.childrenWithName("p")
                if let contactNode = contactNode{
                    print("3、contactNode:\n\(contactNode[0].content!)\n\(contactNode[1].content!)")
                    uploadPerson(node: contactNode, name: name, url: url, position: cellPosition)
                }else{
                    print("5、")
                }
            }*/
        }else{
            print("直接打开")
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
            return
        }
        //print("看之前\n\(name)\n\(adjustUrl)\n\n\n\n\n")
        //头
        if let range = adjustUrl.range(of: "<strong>研究方向") {
            adjustUrl = String(adjustUrl[range.lowerBound...])
        }else if let range = adjustUrl.range(of: "<strong> 研究方向") {
            adjustUrl = String(adjustUrl[range.lowerBound...])
        }else if let range = adjustUrl.range(of: "<strong>学历学位"){
            adjustUrl = String(adjustUrl[range.lowerBound...])
        }else if let range = adjustUrl.range(of: "<span style=\"font-size: 18px\"><strong><span style=\"line-height: 150%; font-family: 'Songti SC Regular'; color: #2e2e2e\">研究方向</span>"){
            adjustUrl = String(adjustUrl[range.lowerBound...])
        }else if let range = adjustUrl.range(of: "<div class=\"teachers_text_con\">"){
            adjustUrl = String(adjustUrl[range.lowerBound...])
        }
        //尾
        if let range = adjustUrl.range(of: "<div class=\"d_page\">"){
            adjustUrl = String(adjustUrl[...range.lowerBound])
        }
        webString = adjustUrl
        //print("看看\n\(name)\n\(adjustUrl)")
    }
    func setUI(){
        avatarImg.image = avatar
        avatarImg.layer.cornerRadius = 4
        nameLb.text = name
        self.navigationItem.title = name
        
        browser.frame = webView.bounds; browser.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        webView.addSubview(browser); browser.navigationDelegate = self
        browser.loadHTMLString(webString, baseURL: url)
        //设置邮箱的点击事件
        let tapGesture = UITapGestureRecognizer.init(target: self, action: #selector(mailTapGesture))
        tapGesture.numberOfTapsRequired = 1
        contactLb.addGestureRecognizer(tapGesture)
    }
    @objc func mailTapGesture(){
        print("打开邮件")
        if contactLb.text!.contains("@") {
            UIApplication.shared.openURL(URL.init(string: "mailto://\(contactLb.text!)")!)
        }
    }
    /*func uploadPerson(node:[JiNode],name:String,url:URL,position:String){
        let object = LocalDocument(className: "TeacherTitleContact")
        object["name"] = name
        object["title"] = node[0].content!
        object["contact"] = node[1].content!
        object["url"] = String.init(describing: url)
        object["position"] = position
        object.saveInBackground { (success:Bool, error:Error?) in
            if success{
                print("成功")
            }else{
                print("失败\(error?.localizedDescription)")
            }
        }
    }*/
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        webView.evaluateJavaScript("document.body.scrollHeight") { value, _ in
            if let height = value as? Double { self.webViewHeight.constant = max(200, CGFloat(height)) }
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

}
