class KeyEventListenerViewController: UIViewController {
    override var canBecomeFirstResponder: Bool {
        return true
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        becomeFirstResponder()
    }

    override func pressesBegan(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        for press in presses {
            if let key = press.key {
                let keyCode = key.keyCode.rawValue
                let keyCharacters = key.charactersIgnoringModifiers
                // Handle key down event
                // print("Key down: \(keyCharacters) (keyCode: \(keyCode))")
                // Send event to React Native side or perform other actions

                ExternalKeyboardListener.shared?.handleKeyPress(
                    keyCode: keyCode,
                    action: 0,
                    pressedKey: keyCharacters
                )
            }
        }
        super.pressesBegan(presses, with: event)
    }

    override func pressesEnded(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        for press in presses {
            if let key = press.key {
                let keyCode = key.keyCode.rawValue
                let keyCharacters = key.charactersIgnoringModifiers
                // Handle key up event
                // print("Key up: \(keyCharacters) (keyCode: \(keyCode))")
                // Send event to React Native side or perform other actions

                ExternalKeyboardListener.shared?.handleKeyPress(
                    keyCode: keyCode,
                    action: 1,
                    pressedKey: keyCharacters
                )
            }
        }
        super.pressesEnded(presses, with: event)
    }
}
