//
//  PersonalInfoModify.swift
//  NewsBang
//
//  Created by 徐炜楠 on 2018/1/11.
//  Copyright © 2018年 徐炜楠. All rights reserved.
//

import UIKit
import RealmSwift

class PersonalInfoModifyVC: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    
    var imageAvatar:UIImage!
    var name:String!
    var number:String!

    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var nameLb: UILabel!
    @IBOutlet weak var numberLb: UILabel!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet var nameField: UITextField!
    
    @IBOutlet weak var changeAvatar: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        //设置图片圆角
        image.layer.cornerRadius = image.frame.height/2
        changeAvatar.layer.cornerRadius = changeAvatar.frame.height/2
        
        //设置初始资源
        image.image = imageAvatar
        nameLb.text = name
        numberLb.text = number
        
        //添加点击事件
        let avatarTap = UITapGestureRecognizer(target: self, action: #selector(avatarChange))
        avatarTap.numberOfTapsRequired = 1
        changeAvatar.addGestureRecognizer(avatarTap)
        
        
        //添加bar上右按钮
        let rightBarItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveChanges))
        self.navigationItem.setRightBarButton(rightBarItem, animated: true)
        
        nameField.isHidden = false
        nameField.text = name
        emailField.isHidden = true
    }
    @objc func saveChanges() {
        do {
            let realm = try Realm()
            let profile = LocalProfile()
            profile.name = nameField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "本地用户"
            profile.avatar = image.image?.pngData() ?? Data()
            try realm.write { realm.add(profile, update: .modified) }
            NotificationCenter.default.post(name: Notification.Name("reload"), object: nil)
            navigationController?.popViewController(animated: true)
        } catch { showLocalError(error) }
    }
    @objc func avatarChange(){
        print("点击成功")
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        image.image = (info[.editedImage] as? UIImage)?.cropToSquare()
        self.dismiss(animated: true, completion: nil)
        changeAvatar.alpha = 0.1
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
