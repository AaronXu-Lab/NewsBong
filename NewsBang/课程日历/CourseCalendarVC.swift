//
//  CourseCalendarVC.swift
//  NewsBang
//
//  Created by 徐炜楠 on 2018/1/18.
//  Copyright © 2018年 徐炜楠. All rights reserved.
//

import UIKit
import EventKit
import RealmSwift

class CourseCalendarVC: UIViewController {
    
    var startDate:Date!
    /**中途变更作息表的时间点，格式为：第几周x100+第几天 */
    var switchTime:Int!
    var courseItems = [CourseItem]()
    var semester = "第一学期"
    var grade = gradeChoose.unchoose
    var gradeInNumber = 2014
    var major = majorChoose.unchoose

    @IBOutlet weak var seniorBtn: UIButton!
    @IBOutlet weak var juniorBtn: UIButton!
    @IBOutlet weak var sophomoreBtn: UIButton!
    @IBOutlet weak var freshmanBtn: UIButton!
    
    @IBOutlet weak var xinwenBtn: UIButton!
    @IBOutlet weak var guangdianBtn: UIButton!
    @IBOutlet weak var guanggaoBtn: UIButton!
    @IBOutlet weak var chuanboBtn: UIButton!
    @IBOutlet weak var bozhuBtn: UIButton!
    
    @IBOutlet weak var addBtn: UIButton!
    var freshmanYear = 2018
    /**现在的时间*/
    var currentTimes = DateComponents()
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        //第一学期还是第二学期？
        semester = (currentTimes.month! >= 2 && currentTimes.month! < 8) ? "第二学期" : "第一学期"
        
        //起始日期
        startDate = numberToDate(year: 2018, month: 9, day: 4)
        switchTime = 5*100+7    //第五周第七天开始执行秋季表
        //"2018-01-15"
        //courseItems.append(CourseItem.init(dayInWeek: 1, classLowToUp: [5,6], name: "西方新闻思想", weeks: [1,2,3,4,6,7], teacher: "刘锐", location: "东九楼D215"))
        
        //finsertEventByCourseItems()
        
    }
    func setUI(){
        let calendar: Calendar = Calendar(identifier: .gregorian)
        currentTimes = calendar.dateComponents([.year,.month,.day, .weekday, .hour, .minute,.second], from: Date())
        freshmanYear = currentTimes.year!
        if currentTimes.month! < 9 {
            freshmanYear -= 1
        }
        seniorBtn.setTitle("\(freshmanYear-3)", for: .normal)
        juniorBtn.setTitle("\(freshmanYear-2)", for: .normal)
        sophomoreBtn.setTitle("\(freshmanYear-1)", for: .normal)
        freshmanBtn.setTitle("\(freshmanYear)", for: .normal)
        
        addBtn.layer.cornerRadius = 4
        
    }
    //以下开始四个按钮的动作模式（暂时只知道这个简单粗暴的方法）
    @IBAction func seniorBtnAction(_ sender: UIButton) {
        seniorBtn.isSelected = true
        juniorBtn.isSelected = false
        sophomoreBtn.isSelected = false
        freshmanBtn.isSelected = false
        
        grade = gradeChoose.senior
        whenFinishChoose()
    }
    @IBAction func juniorBtnAction(_ sender: UIButton) {
        seniorBtn.isSelected = false
        juniorBtn.isSelected = true
        sophomoreBtn.isSelected = false
        freshmanBtn.isSelected = false
        
        grade = gradeChoose.junior
        whenFinishChoose()
    }
    @IBAction func sophomoreBtnAction(_ sender: UIButton) {
        seniorBtn.isSelected = false
        juniorBtn.isSelected = false
        sophomoreBtn.isSelected = true
        freshmanBtn.isSelected = false
        
        grade = gradeChoose.sophomore
        whenFinishChoose()
    }
    @IBAction func freshmanBtnAction(_ sender: UIButton) {
        seniorBtn.isSelected = false
        juniorBtn.isSelected = false
        sophomoreBtn.isSelected = false
        freshmanBtn.isSelected = true
        
        grade = gradeChoose.freshman
        whenFinishChoose()
    }
    //五个按钮的
    @IBAction func xinwenAction(_ sender: UIButton) {
        xinwenBtn.isSelected = true
        guangdianBtn.isSelected = false
        guanggaoBtn.isSelected = false
        chuanboBtn.isSelected = false
        bozhuBtn.isSelected = false
        
        major = majorChoose.xinwen
        whenFinishChoose()
    }
    @IBAction func guangdianAction(_ sender: UIButton) {
        xinwenBtn.isSelected = false
        guangdianBtn.isSelected = true
        guanggaoBtn.isSelected = false
        chuanboBtn.isSelected = false
        bozhuBtn.isSelected = false
        
        major = majorChoose.guangdian
        whenFinishChoose()
    }
    @IBAction func guanggaoAction(_ sender: UIButton) {
        xinwenBtn.isSelected = false
        guangdianBtn.isSelected = false
        guanggaoBtn.isSelected = true
        chuanboBtn.isSelected = false
        bozhuBtn.isSelected = false
        
        major = majorChoose.guanggao
        whenFinishChoose()
    }
    @IBAction func chuanboAction(_ sender: UIButton) {
        xinwenBtn.isSelected = false
        guangdianBtn.isSelected = false
        guanggaoBtn.isSelected = false
        chuanboBtn.isSelected = true
        bozhuBtn.isSelected = false
        
        major = majorChoose.chuanbo
        whenFinishChoose()
    }
    @IBAction func bozhuAction(_ sender: UIButton) {
        xinwenBtn.isSelected = false
        guangdianBtn.isSelected = false
        guanggaoBtn.isSelected = false
        chuanboBtn.isSelected = false
        bozhuBtn.isSelected = true
        
        major = majorChoose.bozhu
        whenFinishChoose()
    }
    //马丹总算结束了
    func whenFinishChoose(){
        guard grade != gradeChoose.unchoose && major != majorChoose.unchoose else{
            return
        }
        gradeInNumber = freshmanYear
        switch grade {
        case gradeChoose.freshman:
            gradeInNumber -= 0
        case gradeChoose.sophomore:
            gradeInNumber -= 1
        case gradeChoose.junior:
            gradeInNumber -= 2
        case gradeChoose.senior:
            gradeInNumber -= 3
        default:
            break
        }
        addBtn.setTitle("\(gradeInNumber-2000)级\(semester)\(major)🐶查询中", for: .disabled)
        print("\(gradeInNumber-2000)级\(semester)\(major)🐶查询中")
        //查询所有标记为true的条目，所有这些条目集合起来然后被转成courseItems数组，集合成一门专业
        let queryCourseItem = LocalQuery(className: "CourseItem")
        queryCourseItem.whereKey("semester", equalTo: semester)
        queryCourseItem.whereKey("gradeInNumber", equalTo: gradeInNumber)
        queryCourseItem.whereKey("major", equalTo: major)
        queryCourseItem.whereKey("isConfirm", equalTo: true)
        queryCourseItem.findObjectsInBackground { (objects:[Any]?, error:Error?) in
            if error == nil{
                if let objects = objects{
                    self.addBtn.setTitle("直接添加", for: .normal)
                    print("课程数量:\(objects.count)\n")
                    guard objects.count>0 else{
                        self.addBtn.setTitle("手动添加", for: .normal)
                        self.addBtn.isEnabled = true
                        return
                    }
                    if self.courseItems.count == 0 {
                        for object in objects{
                            let tempObject = object as AnyObject
                            let dayInWeek = tempObject["dayInWeek"] as! Int
                            let classLowToUp = tempObject["classLowToUp"] as! [Int]
                            let name = tempObject["name"] as! String
                            let weeks = tempObject["weeks"] as! [Int]
                            let teacher = tempObject["teacher"] as! String
                            let location = tempObject["location"] as! String
                            print("打印对象:\ndayInWeek:\(dayInWeek)\nclassLowToUp:\(classLowToUp)\nname:\(name)\nweek:\(weeks)\nteacher:\(teacher)\nlocation:\(location)")
                            let courseItem = CourseItem(dayInWeek: dayInWeek, classLowToUp: classLowToUp, name: name, weeks: weeks, teacher: teacher, location: location)
                            self.courseItems.append(courseItem)
                        }
                    }
                }else{
                    self.addBtn.setTitle("手动添加", for: .normal)
                }
                self.addBtn.isEnabled = true
            }else{
                print("\(self.gradeInNumber-2000)级\(self.semester)\(self.major)🐶查询失败\(error?.localizedDescription)")
            }
        }
        
    }
    
    
    
    @IBAction func addBtnAction(_ sender: UIButton) {
        if sender.title(for: .normal) == "直接添加"{
            insertEventByCourseItems(courseItems: courseItems)
            let finishAlert = UIAlertController(title: "添加成功", message: "请在日历应用中查看", preferredStyle: .alert)
            let gotoRiLi = UIAlertAction(title: "去日历", style: .destructive, handler: { (action) in
                if UIApplication.shared.canOpenURL(URL(string:"calshow:")!) {
                    UIApplication.shared.openURL(URL(string:"calshow:")!)
                }
            })
            let cancel = UIAlertAction(title: "取消", style: .cancel, handler: nil)
            finishAlert.addAction(gotoRiLi)
            finishAlert.addAction(cancel)
            self.present(finishAlert, animated: true, completion: nil)
            
        }else if sender.title(for: .normal) == "手动添加"{
            let manualAddCourseVC = self.storyboard?.instantiateViewController(withIdentifier: "ManualAddCourse") as! ManualAddCourseVC
            
            manualAddCourseVC.title = "\(self.major)\((semester == "第一学期" ? "(上)" : "(下)"))"
            manualAddCourseVC.semester = semester
            manualAddCourseVC.grade = grade
            manualAddCourseVC.gradeInNumber = gradeInNumber
            manualAddCourseVC.major = major
            self.navigationController?.pushViewController(manualAddCourseVC, animated: true)
        }
    }
    //插入文件
    func insertEventByCourseItems(courseItems:[CourseItem]){
        let eventStore = EKEventStore()
        //建立一个课表日历
        var tempCalendar = EKCalendar.init(for: .event, eventStore: eventStore)
        let calendarTitle = "\(grade)\(major)\(semester)"
        if let id = UserDefaults.standard.string(forKey: calendarTitle){
            if let calendar = eventStore.calendar(withIdentifier: id){
                tempCalendar = calendar
            }else{
                //如果获得到了id但是没有这个id对应的日历，那么新建
                tempCalendar.title = calendarTitle
                tempCalendar.source = eventStore.defaultCalendarForNewEvents?.source
                print("存储本地：\(tempCalendar.title)\n\(tempCalendar.calendarIdentifier)")
                do{
                    //print("calendarIdentifier:\(tempCalendar.calendarIdentifier)")
                    try eventStore.saveCalendar(tempCalendar, commit: true)
                    UserDefaults.standard.set(tempCalendar.calendarIdentifier, forKey: calendarTitle)
                }catch{
                    print("error:\(error)")
                }
            }
        }else{
            //如果没有获得到这个id，那么新建
            tempCalendar.title = calendarTitle
            tempCalendar.source = eventStore.defaultCalendarForNewEvents?.source
            print("存储本地：\(tempCalendar.title)\n\(tempCalendar.calendarIdentifier)")
            do{
                //print("calendarIdentifier:\(tempCalendar.calendarIdentifier)")
                try eventStore.saveCalendar(tempCalendar, commit: true)
                UserDefaults.standard.set(tempCalendar.calendarIdentifier, forKey: calendarTitle)
            }catch{
                print("error:\(error)")
            }
        }
        //添加事件
        eventStore.requestFullAccessToEvents(completion: {
            granted, error in
            if (granted) && (error == nil) {
                //print("granted \(granted)")
                //print("error  \(error)")
                for courseItem in courseItems{
                    let events = self.switchCourseItemToEvent(courseItem: courseItem, eventStore: eventStore, calendar: tempCalendar)
                    print("events的数量\(events.count)")
                    for event in events{
                        do{
                            try eventStore.save(event, span: .thisEvent)
                            print("Saved Event")
                        }catch{
                            print("添加失败：\(error)")
                            self.alert(error: "添加失败", message: "请确认日历权限是否打开")
                        }
                    }
                }
            }
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    //把一个CourseItem对象变成EKEvent事件组
    func switchCourseItemToEvent(courseItem:CourseItem,eventStore:EKEventStore,calendar:EKCalendar) -> [EKEvent]{
        var tempCourseItem = courseItem
        var events = [EKEvent]()
        for i in 0..<tempCourseItem.weeks.count{
            let event = EKEvent(eventStore: eventStore)
            event.title = tempCourseItem.name
            let isSummer = ((tempCourseItem.weeks[i]*100 + tempCourseItem.dayInWeek) > switchTime) != (semester == "第一学期")
            print("isSummer:\(isSummer)")
            let dates = inferDates(week: tempCourseItem.weeks[i],
                                   dayInWeek: tempCourseItem.dayInWeek,
                                   classLowToUp: tempCourseItem.classLowToUp,
                                   startDate: startDate,
                                   isSummer: isSummer)
            event.startDate = dates[0]
            event.endDate = dates[1]
            
            event.notes = "上课老师:\((tempCourseItem.teacher!))"
            event.location = tempCourseItem.location
            event.calendar = calendar
            events.append(event)
        }
        return events
    }
    /**从week\dayInWeek\classLowToUp推断出日期*/
    func inferDates(week:Int,dayInWeek:Int,classLowToUp:[Int],startDate:Date,isSummer:Bool) -> [Date]{
        //开始
        var offset = 7*24*60*60*(week-1)
        offset += 24*60*60*(dayInWeek-1)
        if isSummer{
            switch classLowToUp[0]{
            case 1:
                offset += (8*60*60+0*60)
            case 2:
                offset += (8*60*60+55*60)
            case 3:
                offset += (10*60*60+10*60)
            case 4:
                offset += (11*60*60+5*60)
            case 5:
                offset += (14*60*60+30*60)
            case 6:
                offset += (15*60*60+20*60)
            case 7:
                offset += (16*60*60+25*60)
            case 8:
                offset += (17*60*60+15*60)
            case 9:
                offset += (19*60*60+0*60)
            case 10:
                offset += (19*60*60+50*60)
            case 11:
                offset += (20*60*60+45*60)
            case 12:
                offset += (21*60*60+35*60)
            default:
                break
            }
        }else{
            switch classLowToUp[0]{
            case 1:
                offset += (8*60*60+0*60)
            case 2:
                offset += (8*60*60+55*60)
            case 3:
                offset += (10*60*60+10*60)
            case 4:
                offset += (11*60*60+5*60)
            case 5:
                offset += (14*60*60+0*60)
            case 6:
                offset += (14*60*60+50*60)
            case 7:
                offset += (15*60*60+55*60)
            case 8:
                offset += (16*60*60+45*60)
            case 9:
                offset += (18*60*60+30*60)
            case 10:
                offset += (19*60*60+20*60)
            case 11:
                offset += (20*60*60+15*60)
            case 12:
                offset += (21*60*60+05*60)
            default:
                break
            }
        }
        let date1 = Date.init(timeInterval: TimeInterval(offset), since: startDate)
        
        //结束
        var offset2 = 7*24*60*60*(week-1)
        offset2 += 24*60*60*(dayInWeek-1)
        if isSummer{
            switch classLowToUp[1]{
            case 1:
                offset2 += (8*60*60+45*60)
            case 2:
                offset2 += (9*60*60+40*60)
            case 3:
                offset2 += (10*60*60+55*60)
            case 4:
                offset2 += (11*60*60+50*60)
            case 5:
                offset2 += (15*60*60+15*60)
            case 6:
                offset2 += (16*60*60+05*60)
            case 7:
                offset2 += (17*60*60+10*60)
            case 8:
                offset2 += (18*60*60+0*60)
            case 9:
                offset2 += (19*60*60+45*60)
            case 10:
                offset2 += (20*60*60+35*60)
            case 11:
                offset2 += (21*60*60+30*60)
            case 12:
                offset2 += (22*60*60+20*60)
            default:
                break
            }
        }else{
            switch classLowToUp[1]{
            case 1:
                offset2 += (8*60*60+45*60)
            case 2:
                offset2 += (9*60*60+40*60)
            case 3:
                offset2 += (10*60*60+55*60)
            case 4:
                offset2 += (11*60*60+50*60)
            case 5:
                offset2 += (14*60*60+45*60)
            case 6:
                offset2 += (15*60*60+35*60)
            case 7:
                offset2 += (16*60*60+40*60)
            case 8:
                offset2 += (17*60*60+30*60)
            case 9:
                offset2 += (19*60*60+15*60)
            case 10:
                offset2 += (20*60*60+5*60)
            case 11:
                offset2 += (21*60*60+0*60)
            case 12:
                offset2 += (21*60*60+50*60)
            default:
                break
            }
        }
        let date2 = Date.init(timeInterval: TimeInterval(offset2), since: startDate)
        
        var dates = [Date]()
        dates.append(date1)
        dates.append(date2)
        return dates
    }
    /**将三个数字转换为Date*/
    func numberToDate(year:Int,month:Int,day:Int) -> Date{
        var monthStr:String = "\(month)"
        var dayStr:String = "\(day)"
        if month<10{monthStr = "0\(month)"}
        if day<10{dayStr = "0\(day)"}
        let str = "\(year)-\(monthStr)-\(dayStr)"
        let formatter = DateFormatter.init()
        formatter.dateFormat = "yyyy/MM/dd"
        let date = formatter.date(from: str)
        return date!
    }
    func alert(error:String,message:String){
        let alert = UIAlertController(title: error, message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alert.addAction(ok)
        self.present(alert, animated: true, completion: nil)
    }
    struct gradeChoose {
        static let senior = "大四"
        static let junior = "大三"
        static let sophomore = "大二"
        static let freshman = "大一"
        static let unchoose = "未选择"
    }
    struct majorChoose {
        static let xinwen = "新闻"
        static let guangdian = "广电"
        static let guanggao = "广告"
        static let chuanbo = "传播"
        static let bozhu = "播主"
        static let unchoose = "未选择"
    }
}
struct CourseItem {
    var dayInWeek:Int!  //星期几上课
    var classLowToUp = [Int]()  //课程从第几节到第几节
    var name:String!    //课程名字
    var weeks = [Int]()     //上课的周次
    var teacher:String!     //上课老师
    var location:String!    //上课地点
    init(dayInWeek:Int,classLowToUp:[Int],name:String,weeks:[Int],teacher:String,location:String) {
        self.dayInWeek = dayInWeek
        self.classLowToUp = classLowToUp
        self.name = name
        self.weeks = weeks
        self.teacher = teacher
        self.location = location
    }
    func toString(){
        print("课程名\(name!)\n上课老师\(teacher!)\n上课地点\(location!)\n从第\(classLowToUp[0])节到第\(classLowToUp[1])节\n周\(dayInWeek!)\n\(weeks)")
    }
}
