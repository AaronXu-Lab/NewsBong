//
//  TeacherCardVC.swift
//  NewsBang
//
//  Created by 徐炜楠 on 2018/1/14.
//  Copyright © 2018年 徐炜楠. All rights reserved.
//

import UIKit
import Ji

class TeacherCardVC: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource {
    let url = URL(string: "http://sjic.hust.edu.cn/szdw.htm")!
    var xinWenPersons = [TeacherIndex]()
    var guangDianPersons = [TeacherIndex]()
    var guangGaoPersons = [TeacherIndex]()
    var chuanBoPersons = [TeacherIndex]()
    var boZhuPersons = [TeacherIndex]()
    var currentPersons = [TeacherIndex]()
    var layout = UICollectionViewFlowLayout()
    
    @IBOutlet weak var teachersCollectionView: UICollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        DispatchQueue.global().async {
            self.initData()
            self.xinWenPersons = self.initDataWithList(list: self.xinWenPersons)
            DispatchQueue.main.async {
                self.setUI()
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
        }
        //guangDianPersons = initDataWithList(list: guangDianPersons)
        //guangGaoPersons = initDataWithList(list: guangGaoPersons)
        //chuanBoPersons = initDataWithList(list: chuanBoPersons)
        //boZhuPersons = initDataWithList(list: boZhuPersons)
        
        
        /*/打印看看
         for item in xinWenPersons {
         item.toString()
         }
         for item in guangDianPersons {
         item.toString()
         }
         for item in guangGaoPersons {
         item.toString()
         }
         for item in chuanBoPersons {
         item.toString()
         }
         for item in boZhuPersons {
         item.toString()
         }*/
        
        // Do any additional setup after loading the view.
    }
    func setUI(){
        currentPersons = xinWenPersons //新闻优先
        teachersCollectionView.delegate = self
        teachersCollectionView.dataSource = self
        //设置collectionViewFlowLayout
        let itemsize = UIScreen.main.bounds.width/3
        layout.minimumLineSpacing = 3
        layout.minimumInteritemSpacing = 3
        layout.itemSize = CGSize(width: itemsize-2, height: itemsize-2+25)
        teachersCollectionView.collectionViewLayout = layout
        if currentPersons.isEmpty {
            let label = UILabel(); label.text = "数据源暂不可用，请稍后重试"; label.textAlignment = .center
            teachersCollectionView.backgroundView = label
        }
    }
    func initData(){
        guard let doc = Ji(htmlURL: url) else { return }
        func people(_ part: Int) -> [TeacherIndex] {
            let nodes = doc.xPath("//body/div[1]/div[4]/div[1]/div/div[2]/div[\(part)]/a") ?? []
            return nodes.enumerated().compactMap { index, node in
                guard let name = node.content, let href = node.attributes["href"], let address = URL(string: href, relativeTo: url)?.absoluteURL else { return nil }
                return TeacherIndex(name, part, index + 1, address)
            }
        }
        xinWenPersons = people(1); guangDianPersons = people(2); guangGaoPersons = people(3); chuanBoPersons = people(4); boZhuPersons = people(5)
    }
    func initDataWithList(list persons:[TeacherIndex])->[TeacherIndex]{
        var persons = persons
        guard persons.count > 0 else {
            print("这个专业没有老师")
            return persons
        }
        for i in persons.indices {
            let tempObj = persons[i]
            let jiDoc = Ji(htmlURL: tempObj.href)
            var tempImageUrl:String?
            if let imageNode = jiDoc?.xPath("//*[@id=\"vsb_content\"]/dl/dt/div/img")?.first {
                tempImageUrl = (imageNode.attributes["src"])!
            }else if let imageNode = jiDoc?.xPath("//body/div[1]/div[4]/div[1]/div/div[2]/form/dl/dt/div/img")?.first{
                tempImageUrl = (imageNode.attributes["src"])!
            }else if let imageNode = jiDoc?.xPath("//*[@id=\"vsb_content_2\"]/div[1]/p/img")?.first{
                tempImageUrl = (imageNode.attributes["src"])!
            }else if let imageNode = jiDoc?.xPath("//*[@id=\"vsb_content\"]/ul/li[2]/div/img")?.first{
                tempImageUrl = (imageNode.attributes["src"])!
            }else if let imageNode = jiDoc?.xPath("//*[@id=\"Picture 1\"]")?.first{
                tempImageUrl = (imageNode.attributes["src"])!
            }else if let imageNode = jiDoc?.xPath("//*[@id=\"vsb_content\"]/p[2]/img")?.first{
                tempImageUrl = (imageNode.attributes["src"])!
            }else{
                tempImageUrl = nil
                print("\(tempObj.name)为空！")
            }
            //print("\(tempObj.name)\nimageNode1:\((imageNode.attributes["src"])!)")
            persons[i].avatarUrl = tempImageUrl.flatMap { URL(string: $0, relativeTo: tempObj.href)?.absoluteString }
        }
        return persons
    }
    @IBAction func teacherSegment(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            currentPersons = xinWenPersons
        case 1:
            currentPersons = guangDianPersons
        case 2:
            currentPersons = guangGaoPersons
        case 3:
            currentPersons = chuanBoPersons
        case 4:
            currentPersons = boZhuPersons
        default:
            break
        }
        guard currentPersons.count > 0 else {
            currentPersons = initDataWithList(list: currentPersons)
            self.teachersCollectionView.reloadData()
            return
        }
        if currentPersons[0].avatarUrl == nil{
            currentPersons = initDataWithList(list: currentPersons)
        }
        self.teachersCollectionView.reloadData()
    }
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return currentPersons.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! TeacherCardCell
        if let avatarUrl = currentPersons[indexPath.row].avatarUrl {
            //cell.avatar.image = avatar
            //print("加载网络图片：avatar:\(avatarUrl)")
            //加载网络图片，有空试试用ImageHelper
            /*do{
             let url = URL.init(string: avatarUrl)
             let netNsd = try Data.init(contentsOf: url!)
             let netImg = UIImage.init(data: netNsd)
             cell.avatar.image = netImg?.cropToSquare()
             }catch{}*/
            cell.avatar.imageFromURL(avatarUrl, placeholder: UIImage.init(named: "缺省头像")!)
            cell.avatar.layer.cornerRadius = 4
        }else{
            cell.avatar.image = UIImage(named: "缺省头像")
        }
        cell.name.text = currentPersons[indexPath.row].name
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let teacherCardDetail = self.storyboard?.instantiateViewController(withIdentifier: "TeacherCardDetail") as! TeacherCardDetailVC
        let cell = collectionView.cellForItem(at: indexPath) as! TeacherCardCell
        teacherCardDetail.avatar = cell.avatar.image
        teacherCardDetail.name = cell.name.text
        teacherCardDetail.url = currentPersons[indexPath.row].href
        teacherCardDetail.cellPosition = "\(currentPersons[indexPath.row].part)\(currentPersons[indexPath.row].number)"
        self.navigationController?.pushViewController(teacherCardDetail, animated: true)
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
    struct TeacherIndex {
        var name:String
        var part:Int
        var number:Int
        var href:URL
        var avatarUrl:String?
        init() {
            self.name = "none"
            self.part = 0
            self.number = 0
            self.href = URL.init(string: "www.baidu.com")!
            self.avatarUrl = nil
        }
        init(_ name:String,_ part:Int,_ number:Int,_ href:URL) {
            self.name = name
            self.part = part
            self.number = number
            self.href = href
            self.avatarUrl = nil
        }
        func toString(){
            print("name:\(name)\npart:\(part)\nnumber:\(number)\nhref:\(href)\n")
        }
    }
    
}
