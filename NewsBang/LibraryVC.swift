//
//  LibraryVC.swift
//  NewsBang
//
//  Created by 徐炜楠 on 2018/2/16.
//  Copyright © 2018年 徐炜楠. All rights reserved.
//

import UIKit
import Ji

class LibraryVC: UIViewController,UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate {
    
    var searchText = "从你"

    @IBOutlet var tableView: UITableView!
    var searchResult = SearchResult(bookInfoArray: [[]], subheadTitle: [])
    @IBOutlet var searchBar: UISearchBar!
    override func viewDidLoad() {
        super.viewDidLoad()
        //注册列表
        tableView.delegate = self
        tableView.dataSource = self
        //激活搜索框
        searchBar.becomeFirstResponder()
        searchBar.delegate = self
        
        //print("打印图书:\(jiNode)")

        // Do any additional setup after loading the view.
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.view.endEditing(true)
        self.searchText = searchBar.text!
        self.pleaseWait()
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        DispatchQueue.global().async {
            self.searchText = self.searchText.replacingOccurrences(of: " ", with: "+")
            let str = "http://ftp.lib.hust.edu.cn/search*chx/X?SEARCH=\(self.searchText)"
            let encodedStr = str.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
            print("结果网址:\(encodedStr!)")
            self.searchResult = self.seachByUrl(url: encodedStr!)
            DispatchQueue.main.async {
                if self.searchResult.subheadTitle.first == "结果唯一，直接进入" {
                    //print("直接进入结果\(self.searchResult.subheadTitle[1])")
                    self.noticeTop("结果唯一，直接进入")
                    let libraryNext = self.storyboard?.instantiateViewController(withIdentifier: "LibraryNext") as! LibraryNextVC
                    libraryNext.url = self.searchResult.subheadTitle[1]
                    let backBtn = UIBarButtonItem()
                    backBtn.title = "返回"
                    self.navigationItem.backBarButtonItem = backBtn
                    self.navigationController?.pushViewController(libraryNext, animated: true)
                }else if self.searchResult.subheadTitle.count == 0{
                    self.tableView.reloadData()
                    self.noticeTop("未找到结果")
                }else{
                    self.tableView.reloadData()
                    self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: UITableView.ScrollPosition.top, animated: false)
                    self.noticeTop("已获取前50条记录")
                }
                self.clearAllNotice()
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
        }
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return searchResult.subheadTitle.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResult.bookInfoArray[section].count
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 144
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! LibraryCell
        let tempArray = searchResult.bookInfoArray[indexPath.section]
        cell.title.text = tempArray[indexPath.row].title
        cell.author.text = tempArray[indexPath.row].author
        cell.publish.text = tempArray[indexPath.row].publish
        cell.bio.text = tempArray[indexPath.row].bio
        cell.bookImage.imageFromURL(tempArray[indexPath.row].imageUrl, placeholder: UIImage.init(named: "缺省头像")!)
        return cell
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 28))
        view.backgroundColor = UIColor.white
        let line = UIView(frame: CGRect(x: 0, y: 27, width: UIScreen.main.bounds.width, height: 1))
        line.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.05)
        let text = UILabel(frame: CGRect(x: 15, y: 0, width: UIScreen.main.bounds.width-30, height: 28))
        text.text = searchResult.subheadTitle[section]
        text.font = UIFont.systemFont(ofSize: 10)
        text.textColor = UIColor.gray
        view.addSubview(text)
        view.addSubview(line)
        return view
    }
    func seachByUrl(url:String) -> SearchResult{
        
        let jiDoc = Ji(htmlURL: URL(string: url)!)
        var jiNode = jiDoc?.xPath("//body/table")?.first?.children[safe: 9]?.firstChild?.firstChild?.children
        if jiNode == nil {
            jiNode = jiDoc?.xPath("//body/table")?.first?.children[safe: 7]?.firstChild?.firstChild?.children
        }
        //如果只找到一条数据的话，会直接进入结果页，因此要判断
        let countNode = jiDoc?.xPath("//*[@id=\"bibContent\"]/div/div/div/i")?.first
        if countNode?.content == "找到1条记录 "{
            return SearchResult(bookInfoArray: [[]], subheadTitle: ["结果唯一，直接进入",url])
        }
        //如果是未找到，返回空结果
        if jiNode == nil{
            return SearchResult(bookInfoArray: [[]], subheadTitle: [])
        }
        
        var resultCount = 0
        //遍历数组
        var doubleArrayOne = -1
        var doubleArray = [[BookInfo]]()
        var doubleArrayTitle = [String]()
        
        for i in 1..<(jiNode?.count)!{
            let nodeClassInfo = jiNode![i].attributes["class"]
            if nodeClassInfo == "browseHeader"{
                //获取结果的数量
                var resultCountStr = jiNode![i].firstChild?.content
                guard let parts = resultCountStr?.split(separator: "共"), parts.count > 1 else { continue }
                resultCountStr = String(parts[1])
                resultCountStr = resultCountStr!.replacingOccurrences(of: " ", with: "").replacingOccurrences(of: ")\n", with: "")
                resultCount = Int(resultCountStr ?? "") ?? 0
                print("查询结果数量:\(resultCount)")
            }else if nodeClassInfo == nil && jiNode![i].firstChild != nil{
                let contentNode = jiNode![i].firstChild?.firstChild?.firstChild
                if var contentNode = contentNode{
                    if contentNode.children.count >= 4{
                        //如果没有给图的话,给一个默认的图
                        var imageUrl = "http://2016.bookgo.com.cn/book/apiex/getbookimage/isbn/7506603756"
                        if contentNode.children[2].children.count > 3{
                            imageUrl = (contentNode.children[2].children[3].firstChild?.attributes["src"])!
                        }
                        //print("图片地址:\(imageUrl!)")
                        contentNode = contentNode.children[3]
                        guard contentNode.children.count > 3, let href = contentNode.children[1].firstChild?.attributes["href"] else { continue }
                        let nextUrl = "http://ftp.lib.hust.edu.cn\(href)"
                        //print(nextUrl)
                        let title = contentNode.children[1].content?.replacingOccurrences(of: "\n", with: "")
                        let infos = contentNode.children[3].content?.split(separator: "\n")
                        //print("项目\n\(contentNode.children[3])")
                        guard let infos = infos, infos.count >= 2, doubleArrayOne >= 0 else { continue }
                        var author = "\(infos[0])"
                        var publish = "\(infos[1])"
                        var bio = infos.count >= 3 ? "\(infos[2])".contains("Website") ? "暂无简介":"\(infos[2])" : "暂无简介"
                        //如果bio=="更多..."那么说明这个项目没有作者和出版物，那么我们要做出一些调整
                        if bio == "更多..."{
                            bio = author
                            author = "暂无作者"
                            publish = "暂无出版信息"
                        }
                        
                        author = author.replacingOccurrences(of: " ", with: "") == "" ? "暂无简介" : author
                        publish = publish.replacingOccurrences(of: " ", with: "") == "" ? "暂无出版信息" : publish
                        let book = BookInfo(title: title ?? "无标题", author: author, publish: publish, bio: bio, nextUrl: nextUrl, imageUrl: imageUrl)
                        doubleArray[doubleArrayOne].append(book)
                        //print(book.toString() + "\n")
                    }
                }
            }else if jiNode![i].firstChild != nil{
                let subhead = jiNode![i].content
                doubleArrayTitle.append(subhead!)
                doubleArray.append([BookInfo]())
                doubleArrayOne += 1
                //print("\n副标题:\(subhead!)\n----------")
            }
        }
        
        //将最后的subhead上限变成50
        if resultCount > 50, !doubleArrayTitle.isEmpty {
            var tempStr = doubleArrayTitle[doubleArrayTitle.count-1]
            if let low = tempStr.range(of: "-")?.upperBound, let high = tempStr.range(of: " 条记录")?.lowerBound, low <= high { tempStr.replaceSubrange(low..<high, with: "50") }
            doubleArrayTitle[doubleArrayTitle.count-1] = tempStr
        }
        
        let searchResult = SearchResult(bookInfoArray: doubleArray, subheadTitle: doubleArrayTitle)
        return searchResult
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let url = searchResult.bookInfoArray[indexPath.section][indexPath.row].nextUrl
        let libraryNext = self.storyboard?.instantiateViewController(withIdentifier: "LibraryNext") as! LibraryNextVC
        libraryNext.url = url
        let backBtn = UIBarButtonItem()
        backBtn.title = "返回"
        self.navigationItem.backBarButtonItem = backBtn
        self.navigationController?.pushViewController(libraryNext, animated: true)
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
    struct BookInfo {
        var title = ""
        var author = ""
        var publish = ""
        var bio = ""
        var nextUrl = ""
        var imageUrl = ""
        init(title:String,author:String,publish:String,bio:String,nextUrl:String,imageUrl:String) {
            self.title = title
            self.author = author
            self.publish = publish
            self.bio = bio
            self.nextUrl = nextUrl
            self.imageUrl = imageUrl
        }
        func toString() -> String{
            return "书名:\(title)\n作者:\(author)\n出版:\(publish)\n简介:\(bio)\n网址:\(nextUrl)"
        }
    }
    struct SearchResult {
        var bookInfoArray = [[BookInfo]]()
        var subheadTitle = [String]()
        init(bookInfoArray:[[BookInfo]],subheadTitle:[String]) {
            self.bookInfoArray = bookInfoArray
            self.subheadTitle = subheadTitle
        }
    }
}

extension Array { subscript(safe index: Int) -> Element? { indices.contains(index) ? self[index] : nil } }
