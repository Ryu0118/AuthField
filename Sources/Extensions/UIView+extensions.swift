//
//  UIView+extensions.swift
//  
//
//  Created by Ryu on 2022/04/19.
//

import UIKit

extension UIView {
    
    @discardableResult
    func makeHole(at point: CGPoint, radius: CGFloat) -> CAShapeLayer {
        let maskLayer = CAShapeLayer()
        maskLayer.fillRule = .evenOdd
        maskLayer.fillColor = UIColor.black.cgColor
        maskLayer.borderWidth = 2
        maskLayer.borderColor = UIColor.gray.cgColor()
        let maskPath = UIBezierPath(rect: self.frame)
        maskPath.move(to: point)
        maskPath.addArc(withCenter: point, radius: radius, startAngle: 0.0, endAngle: 2.0 * CGFloat.pi, clockwise: true)
        maskLayer.path = maskPath.cgPath
        self.layer.mask = maskLayer
    }
    
    func selected(layer: CAShapeLayer) {
        layer.removeFromSuperlayer()
        layer.borderColor = UIColor.systemBlue.cgColor
        self.layer.mask = layer
    }
    
}

