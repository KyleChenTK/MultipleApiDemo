//
//  APIRequest.swift
//  MultipleApiDemo
//
//  Created by Kyle Chen on 2022/7/18.
//

import Foundation
import UIKit

enum APIurl: String {
    //employee manage page personal Data
    case userManageData = "http://temp1.reformind.com/api/v2/user/userDetail"
    //employee change mugshot
    case userChangeMugshot = "http://34.80.214.106/api/v2/user/editHead"
}

enum APIError:Error{
    case responseProblem
    case decodingProblem
    case encodingProblem
}

struct APIRequest {
    let resourceURL: URL
    
    init (url: APIurl){
        
        guard let resourceURL = URL(string: url.rawValue) else {fatalError()}
        
        self.resourceURL = resourceURL
    }
    
    func getData<T:Codable>(objectToSave:T, completion: @escaping(Result<T,APIError>) -> Void) {
        do{
            var urlRequest = URLRequest(url: self.resourceURL)
            urlRequest.httpMethod = "POST"
            urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            urlRequest.httpBody = try JSONEncoder().encode(objectToSave)
            let dataTask = URLSession.shared.dataTask(with: urlRequest) { data, response, _ in
                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 201,let jsonData = data else {
                    completion(.failure(.responseProblem))
                    return
                }
                do {
                    let objectData = try JSONDecoder().decode(T.self, from: jsonData)
                    completion(.success(objectData))
                }
                catch{
                    completion(.failure(.decodingProblem))
                }
                
            }
            dataTask.resume()
        }
        catch{
            
            completion(.failure(.encodingProblem))
            
        }
        
    }
    
    func useBodyGetData(objectToSave:Data,completion: @escaping(Result<BodyDataResult,APIError>) -> Void) {
        let boundary = "Boundary-\(UIDevice.current.identifierForVendor!.uuidString)"
        var urlRequest = URLRequest(url: self.resourceURL)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("multipart/form-data; boundary=\(boundary)",forHTTPHeaderField: "Content-Type")
        urlRequest.httpBody = objectToSave
        let uploadTask = URLSession.shared.dataTask(with: urlRequest, completionHandler: { (data, response, error) -> Void in
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 201,let jsonData = data else {
                completion(.failure(.responseProblem))
                return
            }
            
            do {
                let objectData = try JSONDecoder().decode(BodyDataResult.self, from: jsonData)
                completion(.success(objectData))
            }
            catch{
                completion(.failure(.decodingProblem))
            }
        })
                                          
        uploadTask.resume()
    }
    
    
}
extension Data {
    //增加直接添加String数据的方法
    mutating func append(_ string: String, using encoding: String.Encoding = .utf8) {
        
        if let data = string.data(using: encoding) {
            
            append(data)
            
        }
        
    }
    
}
func resizeImage(originalImg: UIImage) -> UIImage {
    let width = originalImg.size.width
    let height = originalImg.size.height
    let scale = width / height
    var sizeChange = CGSize()
    if width <= 1280 && height <= 1280{ //图片宽或者高均小于或等于1280时图片尺寸保持不变，不改变图片大小
        return originalImg
    } else if width > 1280 || height > 1280 {//宽或者高大于1280，但是图片宽度高度比小于或等于2，则将图片宽或者高取大的等比压缩至1280
        if scale <= 2 && scale >= 1 {
            let changedWidth: CGFloat = 1280
            let changedheight: CGFloat = changedWidth / scale
            sizeChange = CGSize(width: changedWidth, height: changedheight)
        } else if scale >= 0.5 && scale <= 1 {
            let changedheight: CGFloat = 1280
            let changedWidth: CGFloat = changedheight * scale
            sizeChange = CGSize(width: changedWidth, height: changedheight)
        } else if width > 1280 && height > 1280 {//宽以及高均大于1280，但是图片宽高比大于2时，则宽或者高取小的等比压缩至1280
            if scale > 2 {//高的值比较小
                let changedheight: CGFloat = 1280
                let changedWidth: CGFloat = changedheight * scale
                sizeChange = CGSize(width: changedWidth, height: changedheight)
            } else if scale < 0.5 {//宽的值比较小
                let changedWidth: CGFloat = 1280
                let changedheight: CGFloat = changedWidth / scale
                sizeChange = CGSize(width: changedWidth, height: changedheight)
            }
        } else {// 宽或者高，只有一个大于1280，并且宽高比超过2，不改变图片大小
            return originalImg
        }
    }
    UIGraphicsBeginImageContext(sizeChange)
    originalImg.draw(in: CGRect(x: 0, y: 0, width: sizeChange.width, height: sizeChange.height))
    let resizedImg = UIGraphicsGetImageFromCurrentImageContext()!
    UIGraphicsEndImageContext()
    return resizedImg
}

func compressImageSize(image: UIImage) -> Data {
    var zipImageData = image.jpegData(compressionQuality: 1.0)!
    let originalImgSize = zipImageData.count / 1024 as Int  //获取图片大小
    print("原始大小: \(originalImgSize)")
    if originalImgSize > 1500 {
        zipImageData = image.jpegData(compressionQuality: 0.2)!
    } else if originalImgSize > 600 {
        zipImageData = image.jpegData(compressionQuality: 0.4)!
    } else if originalImgSize > 400 {
        zipImageData = image.jpegData(compressionQuality: 0.6)!
    } else if originalImgSize > 300 {
        zipImageData = image.jpegData(compressionQuality: 0.7)!
    } else if originalImgSize > 200 {
        zipImageData = image.jpegData(compressionQuality: 0.8)!
    }
    return zipImageData
}
