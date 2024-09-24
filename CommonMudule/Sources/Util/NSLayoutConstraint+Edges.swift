//
//  NSLayoutConstraint+Edges.swift

//
//  Created by Carlson Yuan on 2024/5/15.
//  Copyright © 2024 Carlson. All rights reserved.
//

import UIKit

extension NSLayoutConstraint {
    static func constraintsPinningEdges(of view1: UIView, toEdgesOf view2: UIView) -> [NSLayoutConstraint] {
        return constraintsPinningEdges(of: view1, toEdgesOf: view2, withInsets: .zero)
    }
    
    static func constraintsPinningEdges(of view1: UIView, toEdgesOf view2: UIView, withInsets insets: UIEdgeInsets) -> [NSLayoutConstraint] {
        let topConstraint = view1.topAnchor.constraint(equalTo: view2.topAnchor, constant: insets.top)
        let bottomConstraint = view2.bottomAnchor.constraint(equalTo: view1.bottomAnchor, constant: insets.bottom)
        let leftConstraint = view1.leftAnchor.constraint(equalTo: view2.leftAnchor, constant: insets.left)
        let rightConstraint = view2.rightAnchor.constraint(equalTo: view1.rightAnchor, constant: insets.right)
        
        return [topConstraint, bottomConstraint, leftConstraint, rightConstraint]
    }
}

extension UIView {
    func addSubview(_ view: UIView, pinningEdgesWithInsets insets: UIEdgeInsets) {
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        
        let pinningConstraints = NSLayoutConstraint.constraintsPinningEdges(of: view, toEdgesOf: self, withInsets: insets)
        NSLayoutConstraint.activate(pinningConstraints)
    }
}
