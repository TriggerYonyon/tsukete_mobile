//
//  NetworkLayer.swift
//  tsukete
//
//  Created by Kyus'lee on 2022/09/15.
//

import Foundation

enum RestaurantAPIType {
    case justURL(urlString: String)
//    case searchRestaurant(querys: [URLQueryItem])
}

//🔥Error Handling
// Error　プロトコルを遵守しないといけない

enum RestaurantAPIError: Error {
    case badURL
}

class NetworkLayer {
    // typealiasを用いて、typeの別称を定義する
    typealias NetworkCompletion = (_ data: Data?, _ response: URLResponse?, _ error: Error?) -> Void
    
    //@escaping: パラメータTypeの前に記述
    func request(type: RestaurantAPIType, completion: @escaping NetworkCompletion) {
        let sessionConfig = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfig)
        
        do {
            // 🔥間数にthrowsのキーワードがあった場合、tryのキーワードが必要である
            // ⚠️try というキーワードは、代表的にdo catch文という構造内で使わなければならない (tryの扱いは複数の方法がある)
            // ここで、間数の処理が　throwsに落ちて、失敗になったら、catch文の処理を行う
            // 様々な状況でErrorが考えられるとき、そのErrorに対応するためにtryを使う
            let request = try buildRequest(type: type)
            URLSession.shared.dataTask(with: request) { data, response, error in
                print((response as! HTTPURLResponse).statusCode)
                
                completion(data, response, error)
            }.resume()
            // 実行終了させる
            session.finishTasksAndInvalidate()
        } catch {
            print(error)
        }
  
    }
    
    private func buildRequest(type: RestaurantAPIType) throws -> URLRequest {
        switch type {
        case .justURL(urlString: let urlString):
            //Parameterがなく、ただのURLだけでrequestを行う場合
            guard let hasURL = URL(string: urlString) else {
                //正しくURLにアクセスできないとき、上記のenumで作っといたerror typeをthrowするような処理が可能
                throw RestaurantAPIError.badURL
            }
            
            var request = URLRequest(url: hasURL)
            request.httpMethod = "GET"
            return request
        }
    }
}

// 今回は、queryなし
//        case .searchRestaurant(querys: let querys):
//            var components = URLComponents(string: "https://localhost:8080/api/shops")
//            components?.queryItems = querys
//            guard let hasURL = components?.url else {
//                throw RestaurantAPIError.badURL
//            }
//
//            var request = URLRequest(url: hasURL)
//            request.httpMethod = "GET"
//            return request
