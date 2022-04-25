# AuthField
AuthField is Pin Code Field like 2-factor authentication on Apple's homepage.

## Demo
https://user-images.githubusercontent.com/87907656/165143389-57f09ba1-67f6-4949-9eae-22007db81387.mov

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
