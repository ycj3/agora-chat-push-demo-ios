//
//  SettingViewController.swift
//  PushNotifications
//
//  Created by Carlson Yuan on 2024/2/19.
//  Copyright © 2024 Carlson. All rights reserved.
//

import UIKit
import AgoraChat

extension SettingViewController
{
    fileprivate enum Section: Int, CaseIterable
    {
        case pushNotification
        case display
    }
    
    fileprivate enum PushNotificationRow: Int, CaseIterable
    {
        case pushNotificationType
    }
    
    fileprivate enum PushDisplayRow: Int, CaseIterable
    {
        case showMessageContent
        case changeContentTemplate
    }
}
class SettingViewController: UITableViewController
{
    
    @IBOutlet private var showMessageContentSwitch: UISwitch!
    
    private let usecase = PushNotificationUseCase.shared
    private let pushTemplateUsecase = PushNotificationContentTemplateUseCase.shared
    
    public override func viewDidLoad()
    {
        super.viewDidLoad()
        self.navigationItem.title = "Settings"
    }
    
}

private extension SettingViewController
{
    @IBAction func toggleIsShowMessageContentEnabled(_ sender: UISwitch)
    {
        pushTemplateUsecase.setPushNotificationDisplayStyle(style: sender.isOn ? .messageSummary : .simpleBanner)
    }
    
    func changeContentTemplate() {
        pushTemplateUsecase.getPushNotificationContentTemplate { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let templateName):
                    self.presentTextFieldAlert(title: "Change Template", message: "Please input the name of push template", defaultTextFieldMessage: templateName) { temp in
                        PushNotificationContentTemplateUseCase.shared.setPushNotificationContentTemplate(temp: temp)
                    }
                case .failure( _): break
                }
            }
        }
    }
    
    func changePushNotificationType() {
        let actionSheet = UIAlertController(title: "Choose type for push notification", message: nil, preferredStyle: .actionSheet)
        
        let actionTypes: [(title: String, style: UIAlertAction.Style, type: AgoraChatPushRemindType)] = [
            ("All Messages", .default, .all),
            ("Mention Only", .default, .mentionOnly),
            ("None", .destructive, .none)
        ]
        
        for (title, style, type) in actionTypes {
            let action = UIAlertAction(title: title, style: style) { [weak self] _ in
                self?.usecase.setPushNotificationType(type: type)
            }
            actionSheet.addAction(action)
        }
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(actionSheet, animated: true)
    }
    
    @IBAction func SignOut(_ sender: UIButton)
    {
        UserConnectionUseCase.shared.logout(unregisterDeviceToken: true) { [weak self] in
            self?.dismiss(animated: true)
        }
    }
    
}

extension SettingViewController
{
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        let section = Section.allCases[indexPath.section]
        switch section
        {
        case .pushNotification :
            let row = PushNotificationRow.allCases[indexPath.row]
            switch row
            {
            case .pushNotificationType: self.changePushNotificationType()
            }
        case .display:
            let row = PushDisplayRow.allCases[indexPath.row]
            switch row
            {
            case .showMessageContent: break
            case .changeContentTemplate: self.changeContentTemplate()
            }

        }
    }
}
