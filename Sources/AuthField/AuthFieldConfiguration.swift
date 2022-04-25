//
//  AuthFieldConfiguration.swift
//  
//
//  Created by Ryu on 2022/04/25.
//

import UIKit

/// Structures that form AuthField
public struct AuthFieldConfiguration {
    let pinCount: Int
    let font: UIFont
    let spacing: CGFloat
    let boxWidth: CGFloat
    let boxHeight: CGFloat
    let borderColor: UIColor
    let selectedBorderColor: UIColor
    let borderWidth: CGFloat
    let selectedBorderWidth: CGFloat
    let boxCornerRadius: CGFloat
    let boxBackgroundColor: UIColor
    
    public init(
        pinCount: Int,
        font: UIFont = .systemFont(ofSize: 30),
        spacing: CGFloat = CGFloat(17),
        boxWidth: CGFloat = CGFloat(43),
        boxHeight: CGFloat = CGFloat(55),
        borderColor: UIColor = .gray,
        selectedBorderColor: UIColor = .blue,
        borderWidth: CGFloat = CGFloat(2),
        selectedBorderWidth: CGFloat = CGFloat(3),
        boxCornerRadius: CGFloat = CGFloat(8),
        boxBackgroundColor: UIColor = .white
    ) {
        self.pinCount = pinCount
        self.font = font
        self.spacing = spacing
        self.boxWidth = boxWidth
        self.boxHeight = boxHeight
        self.borderColor = borderColor
        self.selectedBorderColor = selectedBorderColor
        self.borderWidth = borderWidth
        self.selectedBorderWidth = selectedBorderWidth
        self.boxCornerRadius = boxCornerRadius
        self.boxBackgroundColor = boxBackgroundColor
    }
}
