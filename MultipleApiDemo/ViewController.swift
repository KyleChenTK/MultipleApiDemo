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
        
        postRequest.getData(objectToSave: userManageData) { result in
            
            switch result {
            case .success(let userManageData):
                print(userManageData.status)
            case .failure(let error):
                print(error)
            }
            
        }
        
    }
    
    func createBody(uid: Int,mugshotImg: UIImage) -> Data {
        let boundary = "Boundary-\(UIDevice.current.identifierForVendor!.uuidString)"
        var body = Data()
        body.append("--\(boundary)\r\n")
        body.append("Content-Disposition: form-data; name=\"uid\"\r\n\r\n")
        body.append("\(uid)\r\n")
        let compressMugshotImage = resizeImage(originalImg: mugshotImg)
        let mugshotData = compressImageSize(image: compressMugshotImage)
        let mugshotName = "staffHeadshotImg"
        let mugshotFileName = "staffHeadshotImg.jpg"
        let mugshotMimeType = "image/jpg"
        body.append("--\(boundary)\r\n")
        body.append("Content-Disposition: form-data; name=\"\(mugshotName)\"; filename=\"\(mugshotFileName)\"\r\n")
        body.append("Content-Type: \(mugshotMimeType)\r\n\r\n")
        body.append(mugshotData)
        body.append("\r\n")
        body.append("--\(boundary)--\r\n")
        return body
    }

}

