//
//  PushNotificationTranslationUseCase.swift
//  PushNotifications
//
//  Created by Carlson Yuan on 2024/3/26.
//  Copyright © 2024 Carlson. All rights reserved.
//

import Foundation
import AgoraChat

class PushNotificationTranslationUseCase {
    func updatePreferredLanguages(for user: String, completion: @escaping(Result<String, Error>) -> Void) {
        AgoraChatClient.shared().pushManager?.setPreferredNotificationLanguage("en", completion: { err in
            if let e = err {
                completion(.failure(NSError(domain: e.errorDescription, code: e.code.rawValue) as Error))
                return
            }
            completion(.success(user))
        })
    }
}
