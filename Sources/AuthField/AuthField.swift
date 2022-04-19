import UIKit
import SnapKit

open class AuthField : UIView {
    
    static let height = CGFloat(55)
    static let boxWidth = CGFloat(25)
    
    private let textField = AuthFieldCore(frame: .zero)

    private var text = "" {
        didSet {
            if text.count <= pinCount {
                textField.text = text
            }
        }
    }
    private var frameObserver: NSKeyValueObservation!
    private var backgroundColorObserver: NSKeyValueObservation!
    
    public var pinCount = 6
    public var pin: Int {
        return Int(text) ?? 0
    }
    public var boxColor = UIColor.white
    public var boxBorderColor = UIColor.gray
    public var boxSelectedColor = UIColor.systemBlue
    
    public init(frame: CGRect, pinCount: Int) {
        self.pinCount = pinCount
        super.init(frame: frame)
        setupViews()
        observeFrame()
    }
    
    required public init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    private func setupViews() {
        self.addSubview(textField)
        textField.snp.makeConstraints {
            $0.height.equalTo(2 * AuthField.height / 3)
            $0.width.equalToSuperview().multipliedBy(0.8)
        }
    }
    
    private func observeFrame() {
        frameObserver = self.observe(\.bounds, options: .new, changeHandler: {[weak self] _, keyObservationChange in
            guard let bounds = keyObservationChange.newValue, let self = self else { return }
            self.textField.defaultTextAttributes.updateValue(36.0,
                 forKey: NSAttributedString.Key.kern)
        })
        
        backgroundColorObserver = self.observe(\.backgroundColor, options: .new, changeHandler: { authField, keyObservationChange in
            guard let optional = keyObservationChange.newValue, let bcColor = optional else { return}
            authField.backgroundColor = authField.boxColor
            //TODO: maskLayerのbackgroundColorを変更
        })
    }
    
    private func calculateSpacing(width: CGFloat) -> CGFloat {
        let pin = CGFloat(pinCount)
        let divide = width / pin
        let boxWidth = CGFloat(25)
        let spacing = divide - boxWidth / 2
        return spacing
    }
}

class AuthFieldCore : UITextField {
    override init(frame: CGRect) {
        super.init(frame: .zero)
        self.backgroundColor = .white
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
