//
//  GroupViewController.swift
//  PushNotifications
//
//  Created by Carlson Yuan on 2023/8/9.
//  Copyright © 2023 carlson. All rights reserved.
//

import UIKit
import AgoraChat

class GroupViewController: UIViewController {
    
    private enum Constant {
        static let loadMoreThreshold: CGFloat = 100
    }
    
    private lazy var tableView: UITableView = {
        let tableView: UITableView = UITableView(frame: .zero, style: .plain)
        tableView.register(BasicMessageCell.self)
        tableView.register(BasicFileCell.self)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 140.0
        tableView.delegate = self
        tableView.dataSource = self
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(sender:)))
        tableView.addGestureRecognizer(longPress)
        return tableView
    }()
    
    private lazy var messageInputView: MessageInputView = {
        let messageInputView = MessageInputView()
        messageInputView.delegate = self
        return messageInputView
    }()
    
    private weak var messageInputBottomConstraint: NSLayoutConstraint?

    var targetMessageForScrolling: AgoraChatMessage?
    let group: AgoraChatGroup
    
    public private(set) lazy var messageListUseCase: GroupMessageListUseCase = {
        let messageListUseCase = GroupMessageListUseCase(group: group)
        messageListUseCase.delegate = self
        return messageListUseCase
    }()

    public private(set) lazy var userMessageUseCase:GroupUserMessageUseCase = {
        let userMessageUseCase = GroupUserMessageUseCase.init(group: group)
        userMessageUseCase.delegate = messageListUseCase
        return userMessageUseCase
    }()

    private lazy var keyboardObserver: KeyboardObserver = {
        let keyboardObserver = KeyboardObserver()
        keyboardObserver.delegate = self
        return keyboardObserver
    }()
    
    init(group: AgoraChatGroup) {
        self.group = group
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
        ])
        
        view.addSubview(messageInputView)
        messageInputView.translatesAutoresizingMaskIntoConstraints = false
        messageInputBottomConstraint = messageInputView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        NSLayoutConstraint.activate([
            messageInputView.topAnchor.constraint(equalTo: tableView.bottomAnchor),
            messageInputView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            messageInputView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            messageInputView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            messageInputView.heightAnchor.constraint(equalToConstant: 50),
            messageInputBottomConstraint
        ].compactMap { $0 })
        
        setupNavigation()
        
        messageListUseCase.loadInitialMessages()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        keyboardObserver.add()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        keyboardObserver.remove()
    }
    
    private func setupNavigation() {
        title = group.groupName
    }
    
    @objc private func handleLongPress(sender: UILongPressGestureRecognizer) {
        guard sender.state == .began else { return }
    }

}

// MARK: - UITableViewDataSource

extension GroupViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        messageListUseCase.messages.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let message = messageListUseCase.messages[indexPath.row]
        let cell: BasicMessageCell = tableView.dequeueReusableCell(for: indexPath)
        cell.configure(with: message)
        return cell
    }

}

// MARK: - UITableViewDelegate

extension GroupViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y - Constant.loadMoreThreshold <= 0 {
             messageListUseCase.loadPreviousMessages()
        }
    }
    
}

// MARK: - GroupMessageListUseCaseDelegate

extension GroupViewController: GroupMessageListUseCaseDelegate {


    func groupMessageListUseCase(_ useCase: GroupMessageListUseCase, didReceiveError error: AgoraChatError) {
        
    }
    func groupMessageListUseCase(_ useCase: GroupMessageListUseCase, didUpdateChannel group: AgoraChatGroup) {
        
    }
    func groupMessageListUseCase(_ useCase: GroupMessageListUseCase, didUpdateMessages messages: [AgoraChatMessage]) {
         tableView.reloadData()
         scrollToFocusMessage()
    }
    func groupMessageListUseCase(_ useCase: GroupMessageListUseCase, didDeleteChannel group: AgoraChatGroup) {
        
    }
    private func scrollToFocusMessage() {
        guard let focusMessage = targetMessageForScrolling,
              focusMessage.messageId == messageListUseCase.messages.last?.messageId else { return }
        self.targetMessageForScrolling = nil

        let focusMessageIndexPath = IndexPath(row: messageListUseCase.messages.count - 1, section: 0)

        tableView.scrollToRow(at: focusMessageIndexPath, at: .bottom, animated: false)
    }
}


// MARK: - MessageInputViewDelegate

extension GroupViewController: MessageInputViewDelegate {
    
    func messageInputView(_ messageInputView: MessageInputView, didTouchUserMessageButton sender: UIButton, message: String) {
        targetMessageForScrolling = userMessageUseCase.sendMessage(message) { [weak self] result in
            switch result {
            case .success(let sendedMessage):
                self?.targetMessageForScrolling = sendedMessage
            case .failure(let error):
                self?.presentAlert(error: error)
            }
        }
    }
    
    func messageInputView(_ messageInputView: MessageInputView, didTouchSendFileMessageButton sender: UIButton) {
    }
    
}

// MARK: - KeyboardObserverDelegate

extension GroupViewController: KeyboardObserverDelegate {
    
    func keyboardObserver(_ keyboardObserver: KeyboardObserver, willShowKeyboardWith keyboardInfo: KeyboardInfo) {
        let keyboardHeight = keyboardInfo.height - view.safeAreaInsets.bottom
        messageInputBottomConstraint?.constant = -keyboardHeight
        
        keyboardInfo.animate { [weak self] in
            self?.view.layoutIfNeeded()
        }
    }
    
    func keyboardObserver(_ keyboardObserver: KeyboardObserver, willHideKeyboardWith keyboardInfo: KeyboardInfo) {
        messageInputBottomConstraint?.constant = keyboardInfo.height
        
        keyboardInfo.animate { [weak self] in
            self?.view.layoutIfNeeded()
        }
    }
    
}
