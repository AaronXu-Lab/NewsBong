//
//  MyCollectionVC.swift
//  NewsBang
//
//  Created by 徐炜楠 on 2018/1/12.
//  Copyright © 2018年 徐炜楠. All rights reserved.
//

import UIKit
import RealmSwift

class MyCollectionVC: UITableViewController {
    var articleItems = [ArticleItems]()
    var footViewHeight:CGFloat?
    var showHistory = false
    override func viewDidLoad() {
        super.viewDidLoad()
        initParameters()
        initFootView()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    func initParameters(){
        do {
            let realm = try Realm()
            let records = realm.objects(LocalArticle.self)
            articleItems = (showHistory ? records : records.filter("isFavorite == true")).sorted(byKeyPath: "visitedAt", ascending: false).map {
                ArticleItems(name: $0.name, date: $0.date, url: $0.url)
            }
            tableView.reloadData()
        } catch { showLocalError(error) }
    }
    override func viewWillAppear(_ animated: Bool) { super.viewWillAppear(animated); initParameters() }
    func initFootView(){
        let footView = UIView()
        footView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: footViewHeight ?? 24)
        footView.backgroundColor = UIColor.white
        let view = UITextView()
        view.text = articleItems.isEmpty ? "暂无记录" : "仅保存在本机"
        view.isEditable = false
        view.font = UIFont.systemFont(ofSize: 8)
        view.textColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
        view.sizeToFit()
        view.frame.origin.x = footView.frame.width/2-view.frame.width/2
        view.frame.origin.y = 2
        
        footView.addSubview(view)
        self.tableView.tableFooterView = footView
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return articleItems.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CollegeNewsCell
        cell.isAccessibilityElement = true
        cell.accessibilityTraits = .button
        cell.accessibilityLabel = articleItems[indexPath.row].name
        cell.name.text = articleItems[indexPath.row].name
        cell.date.text = articleItems[indexPath.row].date
        
        return cell
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 71
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //print("点击了\(indexPath.row),结果\n\(articleItems[indexPath.row].url)")
        let articlePage = self.storyboard?.instantiateViewController(withIdentifier: "ArticlePage") as! ArticlePageVC
        articlePage.url = articleItems[indexPath.row].url
        articlePage.name = articleItems[indexPath.row].name
        //print("str:\(articleItems[indexPath.row].date)")
        articlePage.date = articleItems[indexPath.row].date
        articlePage.from = "我的收藏"
        self.navigationController!.pushViewController(articlePage, animated: true)
    }
    struct ArticleItems {
        var name:String
        var date:String
        var url:String
        init(name:String,date:String,url:String) {
            self.name = name
            self.date = date
            self.url = url
        }
        func toString(){
            print("name:\(name) date:\(date) url:\(url)")
        }
    }
}
