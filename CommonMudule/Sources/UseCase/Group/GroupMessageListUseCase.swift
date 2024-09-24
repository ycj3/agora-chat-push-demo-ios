//
//  GroupMessageListUseCase.swift

//
//  Created by Carlson Yuan on 2023/8/10.
//

import Foundation
import AgoraChat

public protocol GroupMessageListUseCaseDelegate: AnyObject {
    func groupMessageListUseCase(_ useCase: GroupMessageListUseCase, didReceiveError error: AgoraChatError)
    func groupMessageListUseCase(_ useCase: GroupMessageListUseCase, didUpdateMessages messages: [AgoraChatMessage])
}

open class GroupMessageListUseCase: NSObject {
    public weak var delegate: GroupMessageListUseCaseDelegate?
    open var messages: [AgoraChatMessage] = [] {
        didSet {
            notifyChangeMessages()
        }
    }
    open var isLoading: Bool = false
    public private(set) var group: AgoraChatGroup
    private let conversation: AgoraChatConversation?
    let pageSize:Int32 = 20 // load messages pagination
    var startingMessageID: String?
    var hasPrevious: Bool = false // it's likely that there are more messages available in the previous pages
    
    public init(group: AgoraChatGroup) {
        self.group = group
        self.conversation = AgoraChatClient.shared().chatManager?.getConversation(group.groupId, type: .groupChat, createIfNotExist: true)
        super.init()
    }
    
    open func loadInitialMessages() {
        guard let conv = self.conversation else { return }
        // attempt to load from local database
        if let cachedMessages = loadMessagesFromLocalDB(for: conv) {
            self.messages = cachedMessages
        } else {
            // If no cached messages database, load initial messages from network
            let conversationId = conv.conversationId
            let conversationType = AgoraChatConversationType.groupChat
            fetchHistoryMessagesRecursively(conversationId: conversationId!,
                                             conversationType: conversationType,
                                             pageSize: pageSize) { [weak self] (result, error) in
                guard let self = self else { return }
                if let error = error {
                    self.delegate?.groupMessageListUseCase(self, didReceiveError: error)
                    return
                } else if let messages = result {
                    self.appendPreviousMessages(messages)
                }
            }
        }
    }
    
    open func loadMessagesFromLocalDB(for conv: AgoraChatConversation ) -> [AgoraChatMessage]? {
        guard let cachedMessages = conv.loadMessagesStart(fromId: startingMessageID, count: pageSize, searchDirection: .up) else { return nil }
        self.hasPrevious = cachedMessages.count == pageSize
        self.startingMessageID = cachedMessages.first?.messageId
        return cachedMessages.count > 0 ? cachedMessages: nil
    }
    
    open func loadPreviousMessages() {
        guard let conv = self.conversation else { return }
        guard isLoading == false else { return }
        isLoading = true
        if hasPrevious {
            if let messages = loadMessagesFromLocalDB(for: conv) {
                self.appendPreviousMessages(messages)
            } else { print("No messages loaded.") }
        }
    }
    
    func fetchHistoryMessagesRecursively(conversationId: String,
                                         conversationType: AgoraChatConversationType,
                                         pageSize: Int32,
                                         completion: @escaping ([AgoraChatMessage]?, AgoraChatError?) -> Void) {
        let lock = NSLock()
        func fetchRecursively(startMessageId: String?) {
            AgoraChatClient.shared().chatManager?.asyncFetchHistoryMessages(fromServer: conversationId,
                                                                            conversationType: conversationType,
                                                                            startMessageId: startMessageId,
                                                                            fetch: .up,
                                                pageSize: pageSize) { (result, error) in
                lock.lock()
                defer { lock.unlock() }

                if let error = error {
                    completion(nil, error)
                } else if let result = result {
                    // Check if there are more messages to fetch
                    if let messages = result.list {
                        completion(messages, nil)
                        if messages.count == pageSize {
                            if let first = messages.first  {
                                // Fetch next page recursively
                                fetchRecursively(startMessageId: first.messageId)
                            }
                        }
                    } else {
                        print("No messages fetched.")
                        completion(nil, nil)
                    }
                } else {
                    print("No messages fetched.")
                    completion(nil, nil)
                }
            }
        }

        fetchRecursively(startMessageId: nil)
    }
    
    private func appendPreviousMessages(_ newMessages: [AgoraChatMessage]) {
        guard newMessages.isEmpty == false else { return }
        
        messages.insert(contentsOf: newMessages, at: 0)
    }
    
    private func appendNextMessages(_ newMessages: [AgoraChatMessage]) {
        guard newMessages.isEmpty == false else { return }
        
        messages.append(contentsOf: newMessages)
    }

    
    private func notifyChangeMessages() {
        delegate?.groupMessageListUseCase(self, didUpdateMessages: messages)
    }
}

// MARK: - GroupUserMessageUseCaseDelegate

extension GroupMessageListUseCase: GroupUserMessageUseCaseDelegate {
    public func groupUserMessageUseCase(_ useCase: GroupUserMessageUseCase, addedMessages : [AgoraChatMessage]) {
        appendNextMessages(addedMessages)
    }
    public func groupUserMessageUseCase(_ useCase: GroupUserMessageUseCase, didReceiveError error: Error) {
        
    }
}

