# AuthField
AuthField is customizable pin code field like apple 2-factor authentication

![gif](https://user-images.githubusercontent.com/87907656/171995740-c527d8fe-fc5a-4938-b76d-644b051bc157.gif)

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
view.addSubview(authField) 
```

### properties
```Swift
authField.pin = 123456 // default pin code
authField.isSpaceInTheMiddleEnabled = true // Put a space in the middle of the boxes.
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

