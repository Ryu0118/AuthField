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
            self.cards.removeAll()
            self.stackView.removeAllArrangedSubviews()
            self.subviews.forEach { $0.removeFromSuperview() }
            setupView()
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
