//
//  WeiBoCrawlerVC3.swift
//  NewsBang
//
//  Created by 徐炜楠 on 2018/5/17.
//  Copyright © 2018年 徐炜楠. All rights reserved.
//

import UIKit
import Ji

class WeiBoCrawlerVC3: UIViewController {
    var tempImages = [String]()
    override func viewDidLoad() {
        super.viewDidLoad()
        let pages = downloadSearchResult()
        for page in pages {
            print(page)
            let imageUrls = analysicSinglePage(urlStr: page)
            downloadImagesByArray(array: imageUrls)
            
        }
        // Do any additional setup after loading the view.
    }
    func downloadImagesByArray(array:[String]){
        var tempArray = array
        let dir = tempArray.removeLast().split(separator: "|").first
        for i in tempArray{
            if let url = URL(string: i) {
                do{
                    let data = try Data.init(contentsOf: url)
                    let img = UIImage(data: data)
                    let home = NSHomeDirectory() as NSString
                    //打印沙盒路径,可以前往文件夹看到你下载好的图片
                    print(home)
                    let docPath = home.appendingPathComponent("Documents") as NSString
                    print(docPath)
                    let filePath = docPath.appendingPathComponent("\(dir).png")
                    //不得补多少一句在这里卡主了,搜了很多地方都不知道这里怎么写,后来查文档看着需要抛出(try)可是还是不知道怎么写,于是请教了别人,才得以解决
                    do {
                        try (img!.pngData() as? NSData)?.write(toFile: filePath, options: NSData.WritingOptions.atomic)
                    }catch _{
                        
                    }
                }catch{
                    print(error)
                }
            }
        }
    }
    func downloadSearchResult() -> [String]{
        var results = [String]()
        let url = URL(string: "http://www.zcool.com.cn/search/content?&word=%E6%AF%95%E4%B8%9A%20T%E6%81%A4")
        let jiDoc = Ji(htmlURL: url!)
        let mainNode = jiDoc?.xPath("//*[@id=\"body\"]/main/div[4]/div[2]")?.first
        var tempPageUrls = [String]()
        for child in (mainNode?.children)!{
            if child.attributes["data-objid"] == nil{
                continue
            }else{
                results.append((child.firstChild?.firstChild?.attributes["href"])!)
            }
        }
        return results
    }
    func analysicSinglePage(urlStr:String) -> [String]{
        tempImages = []
        let jiDoc = Ji(htmlURL: URL.init(string: urlStr)!)
        let mainNode = jiDoc?.xPath("//*[@id=\"body\"]/main/div[2]/div[2]/div[1]/div")?.first
        analysicNode(node: mainNode!)
        
        tempImages.append((jiDoc?.xPath("//head/title")?.first?.content)!.replacingOccurrences(of: "\n", with: "_"))
        return tempImages
    }
    func analysicNode(node:JiNode) -> Bool{
        //print(node.children.count)
        if node.name! == "img"{
            tempImages.append(node.attributes["src"]!)
        }
        if node.children.count == 0{
            return false
        }else{
            for tempNode in node.children{
                analysicNode(node: tempNode)
            }
            return true
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
