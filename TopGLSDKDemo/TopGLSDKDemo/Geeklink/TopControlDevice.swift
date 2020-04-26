//
//  Fetcher.swift
//  GitHubFetcher
//
//  Created by Artur Rymarz on 06.08.2018.
//  Copyright © 2018 OpenSource. All rights reserved.
//

import Foundation
import Intents

public final class TopControlDevice: NSObject, TopIntentHandling {
   
   
    @available(iOS 12.0, *)
    public func handle(intent: TopIntent, completion: @escaping (TopIntentResponse) -> Void) {
//
        
        let url = URL(string: "https://www.geeklink.com.cn/thinker/jilian/Voice_Assistant.php")!
        
        var request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 10.0)
        request.httpMethod = "POST"
        let dict = NSMutableDictionary()
        dict["iD"] = intent.iD
        dict["homeID"] = intent.homeID
        dict["action"] = intent.action
        dict["type"] = intent.type
        dict["subId"] = intent.subId
        dict["md5"] = intent.md5
        
        let jsonData: Data = try! JSONSerialization.data(withJSONObject: dict, options: JSONSerialization.WritingOptions.prettyPrinted)
        request.httpBody = jsonData

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let urlContent = data {
                    
                    do {
                        
                        let dictionary: NSDictionary = try JSONSerialization.jsonObject(with: urlContent, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary
                        print(dictionary)
                        
                        let _: String = (dictionary.value(forKey: "txt") as! String)
                        let  userActivity: NSUserActivity = NSUserActivity.init(activityType: "ssss")
                        userActivity.title = "ssss"
                        
                        completion(TopIntentResponse(code: .success, userActivity: userActivity))
                        
                        
                    }  catch {
                        let  userActivity: NSUserActivity = NSUserActivity.init(activityType: "ssss")
                        userActivity.title = "ssss"
                        completion(TopIntentResponse(code: .success, userActivity: userActivity))
                        
                    }

                    
                }else {
                    completion(TopIntentResponse(code: .success, userActivity: nil))
                }
            }
            
        }
        
       
        task.resume()
    }
    @available(iOS 12.0, *)
    private func confirm(intent: TopIntent, completion: @escaping (TopIntentResponse) -> Void) {
//        let  userActivity: NSUserActivity = NSUserActivity.init(activityType: "ssss")
//        userActivity.title = "ssss"
        completion(TopIntentResponse(code: .success, userActivity: nil))
        
   
       
    }
    

    

}
