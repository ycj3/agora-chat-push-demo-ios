//
//  GroupListViewController.swift
//  PushNotifications
//
//  Created by Carlson Yuan on 2023/8/7.
//  Copyright © 2023 carlson. All rights reserved.
//
import UIKit
import AgoraChat

final class GroupListViewController: UITableViewController {
    
    private lazy var useCase: GroupListUseCase = {
        let useCase = GroupListUseCase()
        useCase.delegate = self
        return useCase
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Joined Groups"
        useCase.reloadGroups()
    }
}

// MARK: - UITableViewDataSource

extension GroupListViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        useCase.groups.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: GroupListCell = tableView.dequeueReusableCell(for: indexPath)
        let group = useCase.groups[indexPath.row]
        cell.configure(with: group)
        return cell
    }
    
}

// MARK: - UITableViewDelegate

extension GroupListViewController {
    
    public override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let group = useCase.groups[indexPath.row]
        let groupViewController = GroupViewController(group: group)
        groupViewController.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(groupViewController, animated: true)
    }
    
    override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y >= (scrollView.contentSize.height - scrollView.frame.size.height) {
            useCase.loadNextPage()
        }
    }

}

// MARK: - GroupChannelListUseCaseDelegate

extension GroupListViewController: GroupListUseCaseDelegate {
    
    func groupListUseCase(_ groupListUseCase: GroupListUseCase, didReceiveError error: AgoraChatError) {
        DispatchQueue.main.async { [weak self] in
            self?.presentAlert(title: "error", message: error.description)
        }
    }
    func groupListUseCase(_ groupListUseCase: GroupListUseCase, didUpdateGroups groups: [AgoraChatGroup]) {
        DispatchQueue.main.async { [weak self] in
            self?.tableView.reloadData()
        }
    }
    
}
