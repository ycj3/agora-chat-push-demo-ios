//
//  GroupListUseCase.swift

//
//  Created by Carlson Yuan on 2023/8/7.
//

import Foundation
import AgoraChat

public protocol GroupListUseCaseDelegate: AnyObject {
    func groupListUseCase(_ groupListUseCase: GroupListUseCase, didUpdateGroups groups: [AgoraChatGroup])
    func groupListUseCase(_ groupListUseCase: GroupListUseCase, didReceiveError error: AgoraChatError)
}

// MARK: - GroupListUseCase

open class GroupListUseCase: NSObject {
    
    public weak var delegate: GroupListUseCaseDelegate?
    
    public var groups: [AgoraChatGroup] = []
    
    /// Specifies the number of results to return per call. (Default: 20)
    private let limit = 20
    
    /// Boolean indicates there are more data to fetch
    public var hasNext: Bool = false
    
    private var currentCursor = 0
    
    
    private lazy var groupManager: IAgoraChatGroupManager? = {
        let groupManager = AgoraChatClient.shared().groupManager
        groupManager?.add(self, delegateQueue: nil)
        return groupManager
    }()
    
    public override init() {
        super.init()
    }
    
    deinit {
        groupManager?.removeDelegate(self)
    }
    
    open func reloadGroups() {
        self.currentCursor = 0
        self.hasNext = true
        self.loadNextPage()
    }
    
    
    open func loadNextPage() {
        guard self.hasNext else { return }
        groupManager?.getJoinedGroupsFromServer(withPage: currentCursor, pageSize: limit, needMemberCount: false, needRole: false, completion: { [weak self] groups, error in
            guard let self = self else { return }
            if let error = error {
                self.delegate?.groupListUseCase(self, didReceiveError: error)
                return
            }
            guard let groups = groups else { return }
            self.hasNext = !(groups.count < self.limit)
            self.groups.append(contentsOf: groups)
            self.currentCursor += 1
            self.delegate?.groupListUseCase(self, didUpdateGroups: self.groups)
        })
    }

}

// MARK: - GroupListUseCaseDelegate

extension GroupListUseCase: AgoraChatGroupManagerDelegate {
    public func groupListDidUpdate(_ aGroupList: [AgoraChatGroup]) {
        
    }
    public func didJoin(_ aGroup: AgoraChatGroup, inviter aInviter: String, message aMessage: String?) {
        self.hasNext = !(groups.count < limit)
        self.groups.append(contentsOf: groups)
        self.currentCursor += 1
        self.delegate?.groupListUseCase(self, didUpdateGroups: self.groups)
        delegate?.groupListUseCase(self, didUpdateGroups: [aGroup])
    }
    
}
