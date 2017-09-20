//
//  ViewController.swift
//  demo
//
//  Created by Tech on 2017/9/19.
//  Copyright © 2017年 ctc. All rights reserved.
//

import UIKit

public typealias Json = [String: Any]

public let StudentData: Json = [
    "id": 21,
    "name": "小明",
    "age": 12,
]

public let TeacherData: Json = [
    "id": 101,
    "name": "张老师",
    "age": 25,
    "students": [StudentData,StudentData],
    "monitor": StudentData,
    "dic": ["S7":"LCK"],
    "classes":[1,2,3]
]

class Teacher: TCModel {
    var id: Int = 0
    var age: Int = 0
    var name: String!
    
    var classes: [Int]!
    var students: [Student]!
    
    var dic: [String:String]!
    var monitor: Student!
    
    
    override class func objectClassInArray() -> [String : AnyClass] {
        return ["students":Student.classForCoder()]
    }
    
}

class Student: TCModel {
    var id: Int = 0
    var name: String!
    var age: Int = 0
}


class ViewController: UIViewController {
    
    @IBOutlet weak var showTv: UITextView!
    @IBOutlet weak var tf: UITextField!
    var model: Teacher!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        model = Teacher(dictionary: TeacherData)
        log(model)
    }
    
    func log(_ id: Any?) {
        showTv.text = showTv.text + "\n" + (id as AnyObject).description
        print((id as AnyObject).description)
    }
    
    @IBAction func write(_ sender: Any) {
        model.archive(withUserDefaultsKey: tf.text ?? "default")
        log("归档")
    }
    
    @IBAction func read(_ sender: Any) {
        let modelNew = Teacher.unarchive(withUserDefaultsKey: tf.text ?? "default")
        log("读档")
        log(modelNew)
    }
    
    @IBAction func clear(_ sender: Any) {
        showTv.text = ""
    }
}

