//
//  ViewController.swift
//  MultipleApiDemo
//
//  Created by Kyle Chen on 2022/7/18.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let userManageData = UserManageData(uid: 185)
        
        let postRequest = APIRequest(url: .userManageData)
        
        postRequest.save(objectToSave: userManageData) { result in
            
            switch result {
            case .success(let userManageData):
                print(userManageData.status)
            case .failure(let error):
                print(error)
            }
            
        }
        
    }

}

