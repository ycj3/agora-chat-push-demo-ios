//
//  UserConnectionUseCase.swift

//
//  Created by Carlson Yuan on 2024/1/26.
//  Copyright © 2024 Carlson. All rights reserved.
//

import Foundation
import AgoraChat

public class UserConnectionUseCase {
    
    public static let shared = UserConnectionUseCase()
    
    @UserDefault(key: "agora_chat_auto_login", defaultValue: false)
    public private(set) var isAutoLogin: Bool
    
    @UserDefault(key: "agora_chat_user_id", defaultValue: nil)
    public private(set) var userId: String?
    
    public var currentUser: String? {
        AgoraChatClient.shared().currentUsername
    }
        
    private init() {
        
    }
    public func login(userId: String, agoraToken: String,
                      completion: @escaping (Result<String, Error>) -> Void) {
        AgoraChatClient.shared().login(withUsername: userId, agoraToken: agoraToken) { [weak self] username, err in
            if let e = err {
                switch e.code {
                case .userAlreadyLoginSame:
                    break
                default:
                    completion(.failure(NSError(domain: e.errorDescription, code: e.code.rawValue) as Error))
                    return
                }
            }
            self?.storeUserInfo(username)
            completion(.success(username))
        }
    }
      
    private func storeUserInfo(_ username: String) {
        userId = username
        isAutoLogin = true
    }
    
    public func logout(unregisterDeviceToken:Bool, completion: @escaping () -> Void) {
        AgoraChatClient.shared().logout(unregisterDeviceToken) { [weak self]  err in
            self?.isAutoLogin = false
            completion()
        }
    }
}
