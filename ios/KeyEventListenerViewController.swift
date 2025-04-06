class KeyEventListenerViewController: UIViewController {
    private var responderMonitorTimer: Timer?
    override var canBecomeFirstResponder: Bool {
        return true
    }
    func textInputShouldBeginEditing(_ textInput: UITextInput) -> Bool {
        return true
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        becomeFirstResponder()
        //        startMonitoringFirstResponder()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        //        stopMonitoringFirstResponder()
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

    //FIXME: this is useless
    override var keyCommands: [UIKeyCommand]? {
        return KeyEventListenerConstants.specialCommands
    }

    //FIXME: this makes TextInput not focusable
    // private func startMonitoringFirstResponder() {
    //     responderMonitorTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) {
    //         [weak self] _ in
    //         guard let self = self else { return }

    //         // Find the current first responder
    //         if let currentResponder = self.view.window?.findFirstResponder(),
    //             currentResponder !== self
    //         {
    //             // Someone else took first responder — take it back
    //             self.becomeFirstResponder()
    //         }
    //     }
    // }

    // private func stopMonitoringFirstResponder() {
    //     responderMonitorTimer?.invalidate()
    //     responderMonitorTimer = nil
    // }
}
