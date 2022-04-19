//
//  File.swift
//  
//
//  Created by Ryu on 2022/04/20.
//

import UIKit

extension UIStackView {
    
    final func addArrangedSubViews(views: [UIView]) {
        removeAllArrangedSubviews()
        views.forEach {
            self.addArrangedSubview($0)
        }
    }
    
    final func removeAllArrangedSubviews() {
        let removedSubviews = arrangedSubviews.reduce([]) { (allSubviews, subview) -> [UIView] in
            self.removeArrangedSubview(subview)
            return allSubviews + [subview]
        }
        NSLayoutConstraint.deactivate(removedSubviews.flatMap({$0.constraints }))
        removedSubviews.forEach({ $0.removeFromSuperview() })
    }
    
}
