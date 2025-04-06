<a href="https://buymeacoffee.com/bdtren" target="_blank"><img src="https://www.buymeacoffee.com/assets/img/custom_images/orange_img.png" alt="Buy Me A Coffee" style="height: 41px !important;width: 174px !important;box-shadow: 0px 3px 2px 0px rgba(190, 190, 190, 0.5) !important;-webkit-box-shadow: 0px 3px 2px 0px rgba(190, 190, 190, 0.5) !important;" ></a>


# react-native-external-keyboard-listener

React Native listen event from external keyboard.
- It offers the feature to listen all keyboard connection status. Includes: Bluetooth keyboard, Bluetooth scanner, Bluetooth custom keyset,... since I handled it by service id 0x180f and 0x1812 from [Bluetooth devices](https://www.bluetooth.com/wp-content/uploads/Files/Specification/Assigned_Numbers.html)
- It offers functionality similar to [react-native-keyevent](https://github.com/kevinejohn/react-native-keyevent) while eliminating the need for manual modifications to your Android and iOS project folders.  

## Installation

```sh
npm install react-native-external-keyboard-listener 
#OR
yarn add react-native-external-keyboard-listener

npx pod-install
```

### Permissions

- Android: Add these lines to your AndroidManifest.xml:
```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
   ...

   <!-- Android >= 12 -->
   <uses-permission android:name="android.permission.BLUETOOTH_SCAN" />
   <uses-permission android:name="android.permission.BLUETOOTH_CONNECT" />
   <!-- Android < 12 -->
   <uses-permission android:name="android.permission.BLUETOOTH" android:maxSdkVersion="30" />
   <uses-permission android:name="android.permission.BLUETOOTH_ADMIN" android:maxSdkVersion="30" />
   <!-- common -->
   <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" android:maxSdkVersion="30" />

   <!-- Add this line if your application always requires BLE. More info can be found on:
       https://developer.android.com/guide/topics/connectivity/bluetooth-le.html#permissions
     -->
   <uses-feature android:name="android.hardware.bluetooth_le" android:required="true"/>

    ...
```

- iOS: Add this key to your Info.plist:
```xml
<key>NSBluetoothAlwaysUsageDescription</key>
<string>This app requires Bluetooth access</string>
```

## Usage

## API Reference

### `startListening()`
• Signature: `startListening(): void`  
• Description: Begins listening for external keyboard connection status, emitting callbacks “KeyboardConnectionChanged.”  
• Example:  
```tsx
ExternalKeyboardListenerEmitter.startListening();
```

---

### `stopListening()`
• Signature: `stopListening(): void`  
• Description: Stops listening for external keyboard connection status.  
• Example:  
```tsx
ExternalKeyboardListenerEmitter.stopListening();
```

---

### `checkKeyboardConnection()`
• Signature: `checkKeyboardConnection(): Promise<boolean>`  
• Description: Checks if an external keyboard is connected or not.  
• Example:  
```tsx
const isConnected = await ExternalKeyboardListenerEmitter.checkKeyboardConnection();
console.log('Keyboard connected:', isConnected);
```

---

### `isBluetoothEnabled()`
• Signature: `isBluetoothEnabled(): Promise<boolean>`  
• Description: Check if device Bluetooth is enabled or not.
• Example:  
```tsx
await ExternalKeyboardListenerEmitter.isBluetoothEnabled();
```

---

### `enableBluetooth()`
• Signature: `enableBluetooth(): Promise<void>`  
• Description: Opens system Bluetooth settings to allow enabling Bluetooth.  
• Example:  
```tsx
await ExternalKeyboardListenerEmitter.enableBluetooth();
```

---

### `requestBluetoothPermission()`
• Signature: `requestBluetoothPermission(): Promise<boolean>`  
• Description: Requests Bluetooth permissions.  
• Example:  
```tsx
const granted = await ExternalKeyboardListenerEmitter.requestBluetoothPermission();
console.log('Permission granted:', granted);
```

---

### `startKeyPressListener(callback: (event: KeyPressEvent) => void)`
• Signature: `startKeyPressListener(callback: (event: KeyPressEvent) => void): { remove: () => void }`  
• Description: Subscribes to key press events from an external keyboard.
    - Android: Supports all key actions (up, down, unknown,... ), more info: [Android KeyEvents](https://developer.android.com/reference/android/view/KeyEvent)
    - iOS: Supports Key up and Key down events
• Example:  
```tsx
const subscription = ExternalKeyboardListenerEmitter.startKeyPressListener((evt) => {
    console.log('Key pressed:', evt);
});

// Stop listening:
subscription.remove();
```

## Notice: In iOS, when you active TextInput some special key might not be listenable
To get over that issue, you might have to follow these steps:
    1. Add these code to `node_modules/react-native/Libraries/Text/TextInput/Singleline/RCTUITextField.mm` and `node_modules/react-native/Libraries/Text/TextInput/Multiline/RCTUITextField.mm`:
    ```
        #import <ExternalKeyboardListener/ExternalKeyboardListener-Swift.h>

        ...

        - (NSArray<UIKeyCommand *> *)keyCommands {
            //Or you can return any custom handlers by your choice
            return [KeyEventListenerConstants specialCommands];
        }
    ```
    2. Run these command:
    ```
        npm install patch-package postinstall-postinstall -D
        # OR
        yarn add patch-package postinstall-postinstall -D

        npx patch-package react-native
    ```
    3. In your `package.json` file, ensure that this line is added inside `"script"`:

    ```
        "scripts": {
            ...
            "postinstall": "patch-package",
            ...
        },
    ```

## TODO list

- [ ] Fix all //FIXME tags
- [ ] Implement specific bluetooth device listener by name, desciption, service
- [ ] Support virtual keyboard input

## Contributing

See the [contributing guide](CONTRIBUTING.md) to learn how to contribute to the repository and the development workflow.

## License

MIT

---

Made with [create-react-native-library](https://github.com/callstack/react-native-builder-bob)
