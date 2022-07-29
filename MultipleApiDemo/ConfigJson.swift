//
//  ConfigJson.swift
//  MultipleApiDemo
//
//  Created by Kyle Chen on 2022/7/22.
//
import Foundation

final class UserManageData: Codable {
    
    var uid:Int?
    
    var status:String?
    
    var message:String?
    
    init(uid:Int){

        self.uid = uid

    }

}

final class BodyDataResult: Codable {

    var status: String?

    var message: String?
}
