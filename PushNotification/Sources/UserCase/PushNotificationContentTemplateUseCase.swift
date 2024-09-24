//
//  PushNotificationContentTemplateUseCase.swift
//  PushNotifications
//
//  Created by Carlson Yuan on 2024/5/16.
//  Copyright © 2024 Carlson. All rights reserved.
//

import Foundation
import AgoraChat

class PushNotificationContentTemplateUseCase {
    public static let shared = PushNotificationContentTemplateUseCase()
    
    func setPushNotificationDisplayStyle(style: AgoraChatPushDisplayStyle) {
        AgoraChatClient.shared().pushManager?.update(style, completion: { error in
            guard error == nil else {
                // Handle error.
                print("set push display failed. \(error.debugDescription)")
                return
            }
        })
    }
    
    func getPushNotificationContentTemplate(completion: @escaping(Result<String, Error>) -> Void) {
        AgoraChatClient.shared().pushManager?.getPushTemplate({ name, error in
            guard let error = error else {
                print("Currently configured to use the \(name!) template")
                completion(.success(name!))
                return
            }
            print("get push content template failed. \(error.debugDescription)")
            completion(.failure(NSError(domain: error.errorDescription, code: error.code.rawValue) as Error))
        })
    }
    
    func setPushNotificationContentTemplate(temp: String) {
        AgoraChatClient.shared().pushManager?.setPushTemplate(temp, completion: { error in
            guard error == nil else {
                    // Handle error.
                print("set push content template. \(error.debugDescription)")
                return
            }
        })
    }
        
}
