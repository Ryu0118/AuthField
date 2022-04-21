import UIKit
import SnapKit

@objc public protocol AuthFieldDelegate {
    ///Executed after all pin codes have been typed.
    @objc optional func endEditing(_ authField: AuthField, pinCode: Int)
}

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

open class AuthField : UIView {
    
    //MARK: Static Properties
    internal static var boxWidth = CGFloat(43)
    internal static var boxHeight = CGFloat(55)
    
    //MARK: Public Properties
    
    ///The object that acts as the delegate of the authField.
    public weak var delegate: AuthFieldDelegate?
    
    ///Number of pin code digits
    public let pinCount: Int
    
    ///Inputed pin code value
    public var pin: Int {
        get {
            var pin = ""
            cards.compactMap { $0.pin }.forEach { cardPin in
                pin += "\(cardPin)"
            }
            return Int(pin) ?? 0
        }
        set(newPin) {
            let pinArr = Array("\(newPin)")
            let count = pinArr.count
            zip(pinArr, cards).enumerated().forEach { i, data in
                let (pinCode, card) = data
                card.textField.text = "\(pinCode)"
                if i == count - 1 {
                    let lastCard = (i == pinCount - 1) ? card : cards[i + 1]
                    lastCard.textField.isUserInteractionEnabled = true
                }
            }
        }
    }
    
    /**
     The font of the pin code
     */
    public var font = UIFont.systemFont(ofSize: 30) {
        didSet {
            for card in cards {
                card.textField.font = font
            }
        }
    }
    /**
     The distance in points between the adjacent text boxes
     */
    public var spacing = CGFloat(16) {
        didSet {
            stackView.spacing = spacing
        }
    }
    /**
     Border color of unselected text boxes
     */
    public var borderColor: UIColor {
        didSet {
            for card in cards {
                card.setBorderColor(borderColor)
            }
        }
    }
    /**
     Border color of selected text boxes
     */
    public var selectedBorderColor: UIColor {
        didSet {
            for card in cards {
                card.setSelectedBorderColor(borderColor)
            }
        }
    }
    /**
     Border width of selected text boxes
     */
    public var selectedBorderWidth: CGFloat {
        didSet {
            for card in cards {
                card.setSelectedBorderWidth(selectedBorderWidth)
            }
        }
    }
    /**
     Border width of unselected text boxes
     */
    public var borderWidth: CGFloat {
        didSet {
            for card in cards {
                card.setBorderWidth(borderWidth)
            }
        }
    }
    /**
     Corner radius of text boxes
     */
    public var boxCornerRadius: CGFloat {
        didSet {
            for card in cards {
                card.layer.cornerRadius = boxCornerRadius
            }
        }
    }
    /**
     Background color of text boxs
     */
    public var boxBackgroundColor: UIColor {
        didSet {
            for card in cards {
                card.backgroundColor = boxBackgroundColor
            }
        }
    }
    
    //MARK: Internal Properties
    internal var cards = [AuthCard]()
    internal let configuration: AuthFieldConfiguration
    
    //MARK: Private Properties
    private var boundsObserver: NSKeyValueObservation!
    private lazy var stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fillProportionally
        stack.spacing = spacing
        stack.alignment = .center
        return stack
    }()
    
    //MARK: Initializer
    public init(frame: CGRect = .zero, configuration: AuthFieldConfiguration) {
        self.configuration = configuration
        self.font = configuration.font
        self.pinCount = configuration.pinCount
        self.spacing = configuration.spacing
        self.borderColor = configuration.borderColor
        self.selectedBorderColor = configuration.selectedBorderColor
        self.borderWidth = configuration.borderWidth
        self.selectedBorderWidth = configuration.selectedBorderWidth
        self.boxCornerRadius = configuration.boxCornerRadius
        self.boxBackgroundColor = configuration.boxBackgroundColor
        
        AuthField.boxWidth = configuration.boxWidth
        AuthField.boxHeight = configuration.boxHeight
        
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
    
    @discardableResult
    public override func becomeFirstResponder() -> Bool {
        cards.first?.textField.becomeFirstResponder()
        return super.becomeFirstResponder()
    }
    
    ///Delete all pin codes that have been entered
    public func reset() {
        for (i,card) in cards.enumerated() {
            card.delete()
            card.textField.isUserInteractionEnabled = i == 0
        }
    }
    
    //MARK: Private Methods
    private func setupView() {
        self.snp.makeConstraints { $0.height.equalTo(AuthField.boxHeight + 10) }
        
        addSubview(stackView)
        stackView.snp.makeConstraints { $0.edges.equalToSuperview() }
        
        for i in 0..<pinCount {
            let card = AuthCard(font: font)
            card.textField.isUserInteractionEnabled = i == 0
            card.setBorderColor(borderColor)
            card.setSelectedBorderColor(selectedBorderColor)
            card.setBorderWidth(borderWidth)
            card.setSelectedBorderWidth(selectedBorderWidth)
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
