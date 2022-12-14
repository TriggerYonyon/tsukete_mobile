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

//ð¥Error Handling
// Errorããã­ãã³ã«ãéµå®ããªãã¨ãããªã

enum RestaurantAPIError: Error {
    case badURL
}

class NetworkLayer {
    // typealiasãç¨ãã¦ãtypeã®å¥ç§°ãå®ç¾©ãã
    typealias NetworkCompletion = (_ data: Data?, _ response: URLResponse?, _ error: Error?) -> Void
    
    //@escaping: ãã©ã¡ã¼ã¿Typeã®åã«è¨è¿°
    func request(type: RestaurantAPIType, completion: @escaping NetworkCompletion) {
        let sessionConfig = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfig)
        
        do {
            // ð¥éæ°ã«throwsã®ã­ã¼ã¯ã¼ãããã£ãå ´åãtryã®ã­ã¼ã¯ã¼ããå¿è¦ã§ãã
            // â ï¸try ã¨ããã­ã¼ã¯ã¼ãã¯ãä»£è¡¨çã«do catchæã¨ããæ§é åã§ä½¿ããªããã°ãªããªã (tryã®æ±ãã¯è¤æ°ã®æ¹æ³ããã)
            // ããã§ãéæ°ã®å¦çããthrowsã«è½ã¡ã¦ãå¤±æã«ãªã£ãããcatchæã®å¦çãè¡ã
            // æ§ããªç¶æ³ã§Errorãèããããã¨ãããã®Errorã«å¯¾å¿ããããã«tryãä½¿ã
            let request = try buildRequest(type: type)
            URLSession.shared.dataTask(with: request) { data, response, error in
//                if response == nil {
//                    print("ãããã¯ã¼ã¯ã«ç¹ãã£ã¦ãã¾ãã")
//                }
                print((response as! HTTPURLResponse).statusCode)
                
                completion(data, response, error)
            }.resume()
            // å®è¡çµäºããã
            session.finishTasksAndInvalidate()
        } catch {
            print(error)
        }
  
    }
    
    private func buildRequest(type: RestaurantAPIType) throws -> URLRequest {
        switch type {
        case .justURL(urlString: let urlString):
            //Parameterããªãããã ã®URLã ãã§requestãè¡ãå ´å
            guard let hasURL = URL(string: urlString) else {
                //æ­£ããURLã«ã¢ã¯ã»ã¹ã§ããªãã¨ããä¸è¨ã®enumã§ä½ã£ã¨ããerror typeãthrowãããããªå¦çãå¯è½
                throw RestaurantAPIError.badURL
            }
            
            var request = URLRequest(url: hasURL)
            request.httpMethod = "GET"
            return request
        }
    }
}

// ä»åã¯ãqueryãªã
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
