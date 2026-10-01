//
//  ManualAddCourseVC.swift
//  NewsBang
//
//  Created by 徐炜楠 on 2018/1/20.
//  Copyright © 2018年 徐炜楠. All rights reserved.
//

import UIKit
import EventKit
import RealmSwift
//时区
let timeZone = 8

class ManualAddCourseVC: UIViewController {
    
    /**学期开始的日期*/
    var startDate:Date!
    
    var semester:String!
    var grade:String!
    var gradeInNumber = 2014
    var major:String!
    /**课程始终保存到本机*/
    var isShared = true
    @IBOutlet weak var 滑块位置: UIView!
    @IBOutlet weak var dayChooseBtn: UIButton!
    @IBOutlet weak var weekChooseBtn: UIButton!
    @IBOutlet weak var addBtn: UIButton!
    @IBOutlet weak var nameLb: UITextField!
    @IBOutlet weak var teacherLb: UITextField!
    @IBOutlet weak var locationLb: UITextField!
    @IBOutlet weak var maskView: UIView!
    
    let rangeSlider = RangeSlider(frame: CGRect(x: 0, y: 300, width: 200, height: 20))
    
    //初始化数组及参数
    var dayInWeek:Int!  //星期几上课
    var classLowToUp = [Int]()  //课程从第几节到第几节
    var name:String!    //课程名字
    var weeks = [Int]()     //上课的周次
    var teacher:String!     //上课老师
    var location:String!    //上课地点
    var courseItemManual:CourseItem!
    /**中途变更作息表的时间点，格式为：第几周*100+第几天 */
    var switchTime = 5*100+7

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUI()
        
        //初始化起始日期以及中转日期
        switchTime = 5*100+7
        
        
        // Do any additional setup after loading the view.
    }
    func setUI(){
        rangeSlider.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width - 32, height: 滑块位置.frame.height)
        self.滑块位置.addSubview(rangeSlider)
        
        //按钮圆角
        dayChooseBtn.layer.cornerRadius = 4
        weekChooseBtn.layer.cornerRadius = 4
        addBtn.layer.cornerRadius = 4
        
        //设置导航栏图标
        let rightBarItem = UIBarButtonItem.init(title: "设置", style: .plain, target: self, action: #selector(advancedSetting))
        self.navigationItem.setRightBarButton(rightBarItem, animated: true)
    }
    @objc func advancedSetting(){
        let advancedSetting = self.storyboard?.instantiateViewController(withIdentifier: "CourseAdvancedSetting") as! CourseAdvancedSettingVC
        self.navigationController?.pushViewController(advancedSetting, animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isTranslucent = false
        //如果没有设置开始日期，那么这个界面一直存在
        if let startDateFromUserDefaults = UserDefaults.standard.object(forKey: "startDate"){
            maskView.isHidden = true
            startDate = startDateFromUserDefaults as! Date
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.navigationBar.isTranslucent = true
    }
    @IBAction func dayChooseBtnAction(_ sender: UIButton) {
        let marginTop:CGFloat = 0
        let data = ["周一","周二","周三","周四","周五","周六","周日"]
        if sender.tag == HHPickerViewType.single.rawValue{
            let defaultIntegerArr = UserDefaults.standard.array(forKey: "dayChooseDefault") as NSArray?
            let pickerView = HHPickerView.init(frame: CGRect.init(x: marginTop, y: self.view.bounds.size.height, width: self.view.bounds.size.width, height: CGFloat(toolBarH + pickerViewH)), dataSource: data as NSArray, defaultIntegerArr: defaultIntegerArr, pickerType: .single)
            
            pickerView.rowAndComponentCallBack = {(resultStr,selectedArr) in
                self.dayInWeek = (selectedArr![0] as! Int)+1
                //print("str--->\(selectedArr)")
                UserDefaults.standard.set(selectedArr, forKey: "dayChooseDefault")
                sender.setTitle(resultStr! as String, for: .normal)
                
                sender.backgroundColor = UIColor(displayP3Red: 0, green: 122/255, blue: 1, alpha: 1.0)
            }
            pickerView.show()
        }
    }
    @IBAction func weekChooseBtnAction(_ sender: UIButton) {
        let marginTop:CGFloat = 0
        let data = ["第1周","第2周","第3周","第4周","第5周","第6周","第7周","第8周","第9周","第10周","第11周","第12周","第13周","第14周","第15周","第16周","第17周","第18周","第19周","第20周","第21周"]
        if sender.tag == HHPickerViewType.mutable.rawValue {
            let defaultIntegerArr = UserDefaults.standard.array(forKey: "weekChooseDefault") as NSArray?
            let pickerView = HHPickerView.init(frame: CGRect.init(x: marginTop, y: self.view.bounds.size.height, width: self.view.bounds.size.width, height: CGFloat(toolBarH + pickerViewH)), dataSource: data as NSArray, defaultIntegerArr: defaultIntegerArr, pickerType: .mutable)
            
            pickerView.rowAndComponentCallBack = {(resultStr,selectedArr) in
                var selectedArr = selectedArr
                selectedArr = selectedArr?.sorted(by: { (num1, num2) -> Bool in
                    let num1 = num1 as! Int
                    let num2 = num2 as! Int
                    return num1 < num2
                }) as NSArray?
                self.weeks.removeAll()
                for i in 0..<(selectedArr?.count)!{
                    self.weeks.append((selectedArr![i] as! Int)+1)
                }
                //print("str--->\(selectedArr)")
                UserDefaults.standard.set(selectedArr, forKey: "weekChooseDefault")
                sender.setTitle(self.shortWeek(selectedArr: selectedArr) as String, for: .normal)
                
                if selectedArr?.count == 0{
                    sender.backgroundColor = UIColor(displayP3Red: 170/255, green: 170/255, blue: 170/255, alpha: 1.0)
                }else{
                    sender.backgroundColor = UIColor(displayP3Red: 0, green: 122/255, blue: 1, alpha: 1.0)
                }
            }
            pickerView.show()
        }
    }
    /**把“第1周;第2周;第3周”变成“第1-3周”*/
    func shortWeek(selectedArr:NSArray?) -> String{
        let array = selectedArr as! [Int]
        var outStr = ""
        var i = 0
        while i<=21 {
            if !array.contains(i){
                i += 1
                continue
            }else{
                var j = i+1
                print("j\(j)i\(i)")
                while j<=21{
                    if array.contains(j){
                        j += 1
                        continue
                    }else{
                        if (j-1)==i{
                            outStr.append("第\(j-1+1)周;")
                            i = j-1
                            break
                        }else{
                            outStr.append("第\(i+1)-\(j-1+1)周;")
                            i = j
                            break
                        }
                    }
                }
                i = i+1
            }
        }
        if outStr.last == ";" {
            outStr.removeLast()
        }
        return outStr
    }
    @IBAction func shareBtnAction(_ sender: UIButton) {
        sender.isSelected = true
        sender.isEnabled = false
    }
    
    @IBAction func addBtnAction(_ sender: UIButton) {
        //初始化对象数组
        name = nameLb.text!
        teacher = teacherLb.text!
        location = locationLb.text!
        classLowToUp = [Int(rangeSlider.lowerValue),Int(rangeSlider.upperValue)]
        //dayInWeek
        //weeks
        guard name != "" && teacher != "" && location != "" && dayInWeek != nil && weeks.count != 0 else {
            alert(error: "有内容未填写", message: "请确保所有内容都填写完整")
            return
        }
        courseItemManual = CourseItem(dayInWeek: dayInWeek, classLowToUp: classLowToUp, name: name, weeks: weeks, teacher: teacher, location: location)
        
        print("courseItemManual:\(courseItemManual.toString())")
        //添加确认
        let sureAlert = UIAlertController(title: "请确认", message: "起始日期：\(dateToString(date: startDate))\n\(grade!)\(major!)\(semester!)\n\(name!) \(teacher!) \(location!) 星期\(numberToChinese(number: dayInWeek!)) \(classLowToUp[0])-\(classLowToUp[1])节课 \(weekChooseBtn.title(for: .normal)!)", preferredStyle: .alert)
        let sureAction = UIAlertAction(title: "确认", style: .default) { (action) in
            self.pleaseWait()
            //添加至本地日历
            self.insertEventByCourseItemManual(courseItem: self.courseItemManual)
            //保存到本机
            if true { // Always save on this device.
                let object = LocalDocument(className: "CourseItem")
                object["semester"] = self.semester!
                object["gradeInNumber"] = self.gradeInNumber
                object["major"] = self.major!
                object["isConfirm"] = true
                
                object["dayInWeek"] = self.courseItemManual.dayInWeek!
                object["classLowToUp"] = self.courseItemManual.classLowToUp
                object["name"] = self.courseItemManual.name!
                object["weeks"] = self.courseItemManual.weeks
                object["teacher"] = self.courseItemManual.teacher!
                object["location"] = self.courseItemManual.location!
                object.saveInBackground({ (success:Bool, error:Error?) in
                    if success{
                        self.clearAllNotice()
                        self.noticeTop("添加成功", autoClear: true, autoClearTime: 1)
                        //询问是否继续添加
                        let coutinueAlert = UIAlertController(title: "继续添加？", message: "添加成功，是否继续添加？", preferredStyle: .alert)
                        let yesAction = UIAlertAction(title: "继续", style: UIAlertAction.Style.cancel, handler: { (action) in
                            self.nameLb.text = ""
                            self.teacherLb.text = ""
                            self.locationLb.text = ""
                        })
                        let noAction = UIAlertAction(title: "不了", style: .destructive, handler: { (action) in
                            self.navigationController?.popViewController(animated: true)
                        })
                        coutinueAlert.addAction(yesAction)
                        coutinueAlert.addAction(noAction)
                        self.present(coutinueAlert, animated: true, completion: nil)
                    }else{
                        print("上传错误\(error?.localizedDescription)")
                    }
                })
                
                
            }else{
                self.clearAllNotice()
                self.noticeTop("添加成功", autoClear: true, autoClearTime: 1)
                //询问是否继续添加
                let coutinueAlert = UIAlertController(title: "继续添加？", message: "添加成功，是否继续添加？", preferredStyle: .alert)
                let yesAction = UIAlertAction(title: "继续", style: UIAlertAction.Style.cancel, handler: { (action) in
                    self.nameLb.text = ""
                    self.teacherLb.text = ""
                    self.locationLb.text = ""
                })
                let noAction = UIAlertAction(title: "不了", style: .destructive, handler: { (action) in
                    self.navigationController?.popViewController(animated: true)
                })
                coutinueAlert.addAction(yesAction)
                coutinueAlert.addAction(noAction)
                self.present(coutinueAlert, animated: true, completion: nil)
            }
        }
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        sureAlert.addAction(sureAction)
        sureAlert.addAction(cancelAction)
        self.present(sureAlert, animated: true, completion: nil)
    }
    /**把date转成更容易阅读的格式*/
    func dateToString(date:Date)->String{
        let formatter = DateFormatter.init()
        formatter.dateFormat = "yyyy/MM/dd"
        let str = formatter.string(from: date)
        return str
    }
    /**把阿拉伯数字转成中文*/
    func numberToChinese(number:Int)->String{
        var str = ""
        switch number {
        case 1:
            str = "一"
        case 2:
            str = "二"
        case 3:
            str = "三"
        case 4:
            str = "四"
        case 5:
            str = "五"
        case 6:
            str = "六"
        case 7:
            str = "七"
        case 8:
            str = "八"
        case 9:
            str = "九"
        case 0:
            str = "十"
        default: break
        }
        return str
    }
    //插入文件
    func insertEventByCourseItemManual(courseItem:CourseItem){
        let eventStore = EKEventStore()
        //建立一个课表日历
        var tempCalendar = EKCalendar.init(for: .event, eventStore: eventStore)
        let calendarTitle = "\(grade!)\(major!)\(semester!)"
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
                let events = self.switchCourseItemToEvent(courseItem: courseItem, eventStore: eventStore, calendar: tempCalendar)
                print("events的数量\(events.count)")
                for event in events{
                    do{
                        try eventStore.save(event, span: .thisEvent)
                        print("添加成功")
                    }catch{
                        print("添加失败：\(error)")
                        self.alert(error: "添加失败", message: "请确认日历权限是否打开")
                    }
                }
            }
        })
    }
    /**把一个CourseItem对象变成EKEvent事件组*/
    func switchCourseItemToEvent(courseItem:CourseItem,eventStore:EKEventStore,calendar:EKCalendar) -> [EKEvent]{
        var tempCourseItem = courseItem
        var events = [EKEvent]()
        for i in 0..<tempCourseItem.weeks.count{
            let event = EKEvent(eventStore: eventStore)
            event.title = tempCourseItem.name
            var isSummer = false
            let tempDate = weekdayToDate(weekday: tempCourseItem.weeks[i]*100 + tempCourseItem.dayInWeek, startDate: startDate)
            let gregorianCalendar: Calendar = Calendar(identifier: .gregorian)
            let timesComponents = gregorianCalendar.dateComponents([.year,.month,.day, .weekday, .hour, .minute,.second], from: tempDate)
            let dsfasdgas = timesComponents.month!*100+timesComponents.day!
            isSummer = dsfasdgas > (5*100+4) && dsfasdgas < (10*100+8)
            
            //print("isSummer:\(isSummer)")
            var dates = inferDates(week: tempCourseItem.weeks[i],
                                   dayInWeek: tempCourseItem.dayInWeek,
                                   classLowToUp: tempCourseItem.classLowToUp,
                                   startDate: startDate,
                                   isSummer: isSummer)
            //调整时区
            dates[0] = Date(timeInterval: TimeInterval(-1*timeZone*60*60), since: dates[0])
            dates[1] = Date(timeInterval: TimeInterval(-1*timeZone*60*60), since: dates[1])
            
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
        var date = formatter.date(from: str) //直接这么转会偏移8小时的时区
        date = Date(timeInterval: TimeInterval(timeZone*60*60), since: date!)
        return date!
    }
    /***/
    func weekdayToDate(weekday:Int,startDate:Date)->Date{
        let week = weekday/100
        let day = weekday%100
        let second = (week-1)*7*24*60*60+(day-1)*24*60*60
        let date = Date(timeInterval: TimeInterval(second), since: startDate)
        return date
    }
    func dateToWeekday(date:Date,startDate:Date)->Int{
        let second = date.timeIntervalSince(startDate)
        let dayNumber = Int(second/(24*60*60))
        var week:Int = Int(dayNumber/7)
        var day:Int = Int(dayNumber) % 7
        //print("dayNumber\(dayNumber)week\(week)day\(day)")
        if day == 0 && week != 0{
            week -= 1
            day = 7
        }
        return (week+1)*100+(day+1)
    }
    func alert(error:String,message:String){
        let alert = UIAlertController(title: error, message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alert.addAction(ok)
        self.present(alert, animated: true, completion: nil)
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
