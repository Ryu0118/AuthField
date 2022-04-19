import UIKit
import SnapKit

@objc public protocol AuthFieldDelegate {
    @objc optional func endEditing(_ authField: AuthField, pinCode: Int)
}

open class AuthField : UIView {
    //MARK: Public Properties
    public weak var delegate: AuthFieldDelegate?
    public let pinCount: Int
    public var pin: Int {
        var pin = 0
        cards.compactMap { $0.pin }.reversed().enumerated().forEach { i, cardPin in
            var multipled = 1
            if i != 0 { multipled = (1...i).reduce(1) { prev, i -> Int in prev * 10 } }
            pin += cardPin * multipled
        }
        return pin
    }
    
    public var font = UIFont.systemFont(ofSize: 30) {
        didSet {
            
        }
    }
    
    //MARK: Internal Properties
    internal let boxWidth = CGFloat(43)
    internal let boxHeight = CGFloat(55)
    internal var cards = [AuthCard]()
    
    //MARK: Private Properties
    private var boundsObserver: NSKeyValueObservation!
    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fillProportionally
        stack.spacing = 16
        stack.alignment = .center
        return stack
    }()
    
    public init(frame: CGRect = .zero, pinCount: Int) {
        self.pinCount = pinCount
        super.init(frame: frame)
        setupView()
        observeBounds()
    }
    required public init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    //MARK: Public Methods
    @discardableResult
    public override func resignFirstResponder() -> Bool {
        cards.last?.textField.resignFirstResponder()
        return super.resignFirstResponder()
    }
    
    //MARK: Private Methods
    private func setupView() {
        self.snp.makeConstraints { $0.height.equalTo(boxHeight + 10) }
        
        addSubview(stackView)
        stackView.snp.makeConstraints { $0.edges.equalToSuperview() }
        
        for i in 0..<pinCount {
            let card = AuthCard(font: font)
            card.textField.isUserInteractionEnabled = i == 0
            card.tag = i
            card.delegate = self
            stackView.addArrangedSubview(card)
            cards.append(card)
        }
    }
    
}

extension AuthField : AuthCardDelegate {
    
    func endEditing(_ authCard: AuthCard) {
        let index = authCard.tag
        let nextIndex = index + 1
        if let card = cards[safe: nextIndex] {
            card.textField.isUserInteractionEnabled = true
            card.textField.becomeFirstResponder()
            authCard.textField.isUserInteractionEnabled = false
        }
        else if nextIndex == pinCount {
            authCard.textField.isUserInteractionEnabled = true
            delegate?.endEditing?(self, pinCode: pin)
        }
    }
    
    func didRemove(_ authCard: AuthCard, isRemoveNext: Bool) {
        let index = authCard.tag
        if let card = cards[safe: index - 1] {
            if isRemoveNext { card.textField.text = "" }
            card.textField.isUserInteractionEnabled = true
            card.textField.becomeFirstResponder()
            authCard.textField.isUserInteractionEnabled = false
        }
        else if index == 0 {
            authCard.textField.isUserInteractionEnabled = true
        }
    }
    
    func textFieldDidOverRange(_ authCard: AuthCard, remaining: String) {
        let index = authCard.tag
        let nextIndex = index + 1

        if let card = cards[safe: nextIndex] {
            card.textField.text = remaining
            authCard.textField.text?.removeLast()
            card.textField.isUserInteractionEnabled = true
            card.textField.becomeFirstResponder()
            authCard.textField.isUserInteractionEnabled = false
            
            if card.tag + 1 == pinCount {
                card.textField.resignFirstResponder()
                card.textField.isUserInteractionEnabled = true
                delegate?.endEditing?(self, pinCode: pin)
            }
        }
        else if nextIndex == pinCount {
            authCard.textField.isUserInteractionEnabled = true
            authCard.textField.text = remaining
            delegate?.endEditing?(self, pinCode: pin)
        }
    }
    
}


protocol AuthCardDelegate : AnyObject {
    func endEditing(_ authCard: AuthCard)
    func didRemove(_ authCard: AuthCard, isRemoveNext: Bool)
    func textFieldDidOverRange(_ authCard: AuthCard, remaining: String)
}

class AuthCard : UIView {
    
    weak var delegate: AuthCardDelegate?
    
    let width = CGFloat(43)
    let height = CGFloat(55)
    let font: UIFont
    
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
        textField.backgroundColor = .white
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
        self.layer.borderWidth = 2
        self.layer.borderColor = UIColor.lightGray.cgColor
        self.layer.cornerRadius = 8
        setupView()
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    private func setupView() {
        textField.addTarget(self, action: #selector(editingChanged), for: .editingChanged)
        textField.addTarget(self, action: #selector(startEditing), for: .editingDidBegin)
        textField.addTarget(self, action: #selector(finishEditing), for: .editingDidEnd)
        textField.addTarget(self, action: #selector(textFieldDidTouch), for: .allTouchEvents)
        addSubview(textField)
        
        self.snp.makeConstraints {
            $0.width.equalTo(width)
            $0.height.equalTo(height)
        }
        textField.snp.makeConstraints {
            $0.centerX.centerY.equalToSuperview()
            $0.width.equalTo(width * 0.9)
            $0.height.equalTo(height * 0.9)
        }
    }

    private func selected() {
        self.layer.borderWidth = 3
        self.layer.borderColor = UIColor.systemBlue.cgColor
    }
    
    private func deselected() {
        self.layer.borderWidth = 2
        self.layer.borderColor = UIColor.lightGray.cgColor
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
        self.tintColor = .white
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func deleteBackward() {
        if let text = text, text.isEmpty {
            didDelete?()
        }
        super.deleteBackward()
    }
    
}
