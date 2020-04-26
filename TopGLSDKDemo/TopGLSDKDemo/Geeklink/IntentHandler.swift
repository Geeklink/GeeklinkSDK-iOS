//
//  IntentHandler.swift
//  MilkshakrIntents
//
//  Created by Guilherme Rambo on 15/07/18.
//  Copyright © 2018 Guilherme Rambo. All rights reserved.
//

import Intents

class IntentHandler: INExtension {
    
    override func handler(for intent: INIntent) -> Any? {
        if #available(iOS 12.0, *) {
             
            if intent is TopIntent {
                return TopControlDevice()
            }
        } else {
            // Fallback on earlier versions
        }
        return nil
    }
   
    

   


}
