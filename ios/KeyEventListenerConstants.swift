@objc(KeyEventListenerConstants)
public class KeyEventListenerConstants: NSObject {
    @objc public static var supportedSpecialKeyCodes: [Int] = [
        58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69,
        76, 119, 41, 41, 115, 121, 116, 80, 79, 81, 82,
    ]

    @available(iOS 15.0, *)
    @objc public static var supportedSpecialKeyInputs: [String] = [
        UIKeyCommand.f1, UIKeyCommand.f2, UIKeyCommand.f3, UIKeyCommand.f4,
        UIKeyCommand.f5, UIKeyCommand.f6, UIKeyCommand.f7, UIKeyCommand.f8,
        UIKeyCommand.f9, UIKeyCommand.f10, UIKeyCommand.f11, UIKeyCommand.f12,
        UIKeyCommand.inputDelete, UIKeyCommand.inputEnd, "\u{1b}", UIKeyCommand.inputEscape,
        UIKeyCommand.inputHome, UIKeyCommand.inputPageDown, UIKeyCommand.inputPageUp,
        UIKeyCommand.inputLeftArrow, UIKeyCommand.inputRightArrow,
        UIKeyCommand.inputDownArrow, UIKeyCommand.inputUpArrow,
    ]
   @objc public static var specialCommands: [UIKeyCommand] = KeyEventListenerConstants.setupKeyCommands()

    @objc private static func setupKeyCommands() -> [UIKeyCommand] {
        var commands: [UIKeyCommand] = []
        if #available(iOS 15.0, *) {
            for input in KeyEventListenerConstants.supportedSpecialKeyInputs {
                // print("key init ===----->\(input)")
                commands.append(
                    UIKeyCommand(
                        input: input, modifierFlags: [],
                        action: #selector(KeyEventListenerConstants.handleKeyUp(_:)))
                )
            }
        } else {
            // Fallback on earlier versions
        }
        return commands
    }

    @objc static func handleKeyUp(_ cmd: UIKeyCommand) {
        // print("handleKeyUp ----------------->\(cmd.input ?? "")")
        if #available(iOS 15.0, *) {
            let keyCodeIdx = KeyEventListenerConstants.supportedSpecialKeyInputs.firstIndex(
                where: { it in
                    it == cmd.input
                })
            let keyCode = KeyEventListenerConstants.supportedSpecialKeyCodes[keyCodeIdx ?? 0]
            ExternalKeyboardListener.shared?.handleKeyPress(
                keyCode: keyCode,
                action: 1,
                pressedKey: cmd.input ?? ""
            )
        } else {
            // Fallback on earlier versions
        }
        
    }
}
