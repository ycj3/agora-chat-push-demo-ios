//
//  TabBarController.swift

//
//  Created by Carlson Yuan on 2024/5/21.
//  Copyright © 2024 Carlson. All rights reserved.
//

import UIKit
class TabBarController: UITabBarController
{
    override func viewDidLoad() {
        super.viewDidLoad()
        // Change text color for normal state
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.gray], for: .normal)
                
        // Change text color for selected state
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.white], for: .selected)
        
        tabBar.backgroundColor = UIColor.samplesPrimary

    }
}
