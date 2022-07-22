//
//  APIRequest.swift
//  MultipleApiDemo
//
//  Created by Kyle Chen on 2022/7/18.
//

import Foundation

enum APIurl: String {
    //employee manage page personal Data
    case userManageData = "http://temp1.reformind.com/api/v2/user/userDetail"
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
    
    func save<T:Codable>(objectToSave:T, completion: @escaping(Result<T,APIError>) -> Void) {
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
  
}
