# react-native-external-keyboard-listener

React Native listen event from external keyboard

## Installation

```sh
npm install react-native-external-keyboard-listener OR yarn add

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
• Description: Begins listening for external keyboard events, emitting callbacks such as “OnKeyPress” or “KeyboardConnectionChanged.”  
• Example:  
```tsx
ExternalKeyboardListenerEmitter.startListening();
```

---

### `stopListening()`
• Signature: `stopListening(): void`  
• Description: Stops listening for external keyboard events and releases related resources.  
• Example:  
```tsx
ExternalKeyboardListenerEmitter.stopListening();
```

---

### `checkKeyboardConnection()`
• Signature: `checkKeyboardConnection(): Promise<boolean>`  
• Description: Checks if an external keyboard is present.  
• Example:  
```tsx
const isConnected = await ExternalKeyboardListenerEmitter.checkKeyboardConnection();
console.log('Keyboard connected:', isConnected);
```

---

### `isBluetoothEnabled()`
• Signature: `isBluetoothEnabled(): Promise<boolean>`  
• Description: Check if Bluetooth is enabled or not 
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
• Description: Requests Bluetooth permissions on Android.  
• Example:  
```tsx
const granted = await ExternalKeyboardListenerEmitter.requestBluetoothPermission();
console.log('Permission granted:', granted);
```

---

### `startKeyPressListener(callback: (event: KeyPressEvent) => void)`
• Signature: `startKeyPressListener(callback: (event: KeyPressEvent) => void): { remove: () => void }`  
• Description: Subscribes to key press events from an external keyboard.  
• Example:  
```tsx
const subscription = ExternalKeyboardListenerEmitter.startKeyPressListener((evt) => {
    console.log('Key pressed:', evt);
});

// Stop listening:
subscription.remove();
```


## Contributing

See the [contributing guide](CONTRIBUTING.md) to learn how to contribute to the repository and the development workflow.

## License

MIT

---

Made with [create-react-native-library](https://github.com/callstack/react-native-builder-bob)
