//
//  AuthCard.swift
//  
//
//  Created by Ryu on 2022/04/20.
//

import UIKit
import SnapKit

protocol AuthCardDelegate : AnyObject {
    func endEditing(_ authCard: AuthCard)
    func didRemove(_ authCard: AuthCard, isRemoveNext: Bool)
    func textFieldDidOverRange(_ authCard: AuthCard, remaining: String)
}

class AuthCard : UIView {
    
    weak var delegate: AuthCardDelegate?

    let font: UIFont
    
    var selectedBorderColor: UIColor = .systemBlue
    var borderColor: UIColor = .lightGray
    var borderWidth: CGFloat = 2
    var selectedBorderWidth: CGFloat = 3
    
    var pin: Int? {
        if let text = textField.text {
            return Int(text)
        }
        else {
            return nil
        }
    }
    
    lazy var textField: AuthTextField = {
        let textField = AuthTextField(frame: .zero)
        textField.backgroundColor = .clear
        textField.keyboardType = .numberPad
        textField.font = font
        textField.textAlignment = .center
        
        textField.didDelete = {[weak self] in
            guard let self = self else { return }
            textField.resignFirstResponder()
            self.delegate?.didRemove(self, isRemoveNext: true)
        }
        
        return textField
    }()
    
    init(font: UIFont) {
        self.font = font
        super.init(frame: .zero)
        self.layer.borderWidth = borderWidth
        self.layer.borderColor = borderColor.cgColor
        self.layer.cornerRadius = 8
        setupView()
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    func delete() {
        textField.text = ""
    }
    
    func setBorderColor(_ borderColor: UIColor) {
        self.borderColor = borderColor
        self.layer.borderColor = borderColor.cgColor
    }
    
    func setSelectedBorderColor(_ color: UIColor) {
        self.selectedBorderColor = color
    }
    
    func setBorderWidth(_ width: CGFloat) {
        self.layer.borderWidth = width
        self.borderWidth = width
    }
    
    func setSelectedBorderWidth(_ width: CGFloat) {
        self.selectedBorderWidth = width
    }
    
    private func setupView() {
        textField.addTarget(self, action: #selector(editingChanged), for: .editingChanged)
        textField.addTarget(self, action: #selector(startEditing), for: .editingDidBegin)
        textField.addTarget(self, action: #selector(finishEditing), for: .editingDidEnd)
        textField.addTarget(self, action: #selector(textFieldDidTouch), for: .allTouchEvents)
        addSubview(textField)
        
        self.snp.makeConstraints {
            $0.width.equalTo(AuthField.boxWidth)
            $0.height.equalTo(AuthField.boxHeight)
        }
        textField.snp.makeConstraints {
            $0.centerX.centerY.equalToSuperview()
            $0.width.equalTo(AuthField.boxWidth * 0.9)
            $0.height.equalTo(AuthField.boxHeight * 0.9)
        }
    }

    private func selected() {
        self.layer.borderWidth = selectedBorderWidth
        self.layer.borderColor = selectedBorderColor.cgColor
    }
    
    private func deselected() {
        self.layer.borderWidth = borderWidth
        self.layer.borderColor = borderColor.cgColor
    }
}

@objc private extension AuthCard {
    
    func textFieldDidTouch() {
        let newPosition = textField.endOfDocument
        textField.selectedTextRange = textField.textRange(from: newPosition, to: newPosition)
    }
    
    func startEditing() {
        selected()
    }
    
    func finishEditing() {
        deselected()
    }
    
    func editingChanged() {
        if let count = textField.text?.count {
            if (count > 0 && Int(textField.text ?? "") == nil)  {
                textField.text?.removeAll()
                return
            }
            if count == 1 {
                textField.resignFirstResponder()
                delegate?.endEditing(self)
            }
            else if count == 0 {
                textField.resignFirstResponder()
                delegate?.didRemove(self, isRemoveNext: false)
            }
            else if count > 1 {
                textField.resignFirstResponder()
                delegate?.textFieldDidOverRange(self, remaining: "\(textField.text?.last ?? Character(""))")
            }
        }
    }
}

class AuthTextField : UITextField {
    
    var didDelete: (() -> ())?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.tintColor = .clear
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func deleteBackward() {
        if let text = text, text.isEmpty {
            didDelete?()
        }
        super.deleteBackward()
    }
    
    override func caretRect(for position: UITextPosition) -> CGRect {
        return .zero
    }
   
    override func selectionRects(for range: UITextRange) -> [UITextSelectionRect] {
        return []
    }
   
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if action == #selector(UIResponderStandardEditActions.copy(_:)) || action == #selector(UIResponderStandardEditActions.selectAll(_:)) || action == #selector(UIResponderStandardEditActions.paste(_:)) {
            return false
        }
        return super.canPerformAction(action, withSender: sender)
    }
    
}
