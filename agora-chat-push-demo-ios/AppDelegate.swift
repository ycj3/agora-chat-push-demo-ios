//
//  AppDelegate.swift
//  PushNotifications
//
//  Created by easemob on 024/1/25.
//  Copyright © 2024 Carlson. All rights reserved.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {
        EnvironmentUseCase.initializeAgoraChatSDK(appKey: .sample, apnsCertName: "dev_push_notification_chat")
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.backgroundColor = .samplesPrimary
        window?.rootViewController = createLoginViewController()
        window?.makeKeyAndVisible()
        
        self.registerForPushNotifications()
        
        return true
    }
    
    private func createLoginViewController() -> LoginViewController {
        return LoginViewController(didConnectUser: { [weak self] user in
            self?.updatePreferredLanguages(for: user)
            self?.presentMainViewController()
        })
    }
    
    private func updatePreferredLanguages(for user: String) {
        PushNotificationTranslationUseCase().updatePreferredLanguages(for: user) { result in
            // Handle result
            print(result)
        }
    }
    
    private func presentMainViewController() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let tabBarController = storyboard.instantiateInitialViewController() {
            window?.rootViewController?.present(tabBarController, animated: true)
        } else {
            print("Unable to instantiate initial view controller from storyboard.")
        }
    }
    
    private func registerForPushNotifications() {
      UNUserNotificationCenter.current()
        .requestAuthorization(options: [.alert, .sound, .badge]) { [weak self] granted, _ in
            guard granted else { return }
            self?.getNotificationSettings()
        }
    }
    
    private func getNotificationSettings() {
      UNUserNotificationCenter.current().getNotificationSettings { settings in
          guard settings.authorizationStatus == .authorized else { return }
          DispatchQueue.main.async {
              // register for Remote Notifications:
            UIApplication.shared.registerForRemoteNotifications()
          }
      }
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        // register a device token to the Agora Chat server
        PushNotificationUseCase.shared.registerDeviceToken(deviceToken: deviceToken)
        
        let tokenString = hexadecimalString(fromData: deviceToken)
        print("Device Token: \(tokenString)")
    }
    func hexadecimalString(fromData data: Data) -> String {
        let hexString = data.map { String(format: "%02.2hhx", $0) }.joined()
        return hexString
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register for remote notifications: \(error.localizedDescription)")
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        let payload = userInfo as NSDictionary
        print("User Info payload:", payload)
        // let alertMsg = (userInfo["aps"] as! NSDictionary)["alert"] as! NSDictionary
        // print("Alert Message:", alertMsg)
        // Implement your custom way to parse payload
        if (application.applicationState == .inactive) {
            // Receiving a notification while your app is inactive.
        } else {
            // Receiving a notification while your app is in either foreground or background.
        }
        completionHandler(UIBackgroundFetchResult.newData)
    }
}
