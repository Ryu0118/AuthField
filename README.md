# AuthField
AuthField is customizable pin code field.

## Installation
`pod 'AuthField'`

## Usage

```Swift
let authField = AuthField(pinCount: 6)
view.addSubview(authField)
```
### Customization
```Swift
let authFieldConfiguration = AuthFieldConfiguration(
    pinCount: 6,
    font: .boldSystemFont(ofSize: 25),
    spacing: 12,
    boxWidth: 42,
    boxHeight: 52,
    borderColor: .lightGray,
    selectedBorderColor: .systemGreen,
    borderWidth: 1,
    selectedBorderWidth: 2,
    boxCornerRadius: 12,
    boxBackgroundColor: .white
)
let authField = AuthField(configuration: authFieldConfiguration)
authField.pin = 123456 // default pin code
authField.isSpaceInTheMiddleEnabled = true // Put a space in the middle of the boxes.
view.addSubview(authField) 
```

### Delegation
```Swift
authField.delegate = self
``` 
Called when all pin codes have been entered
```Swift 
extension ViewController : AuthFieldDelegate {
    func endEditing(_ authField: AuthField, pinCode: Int) {
        print(pinCode)
    }
}
```

