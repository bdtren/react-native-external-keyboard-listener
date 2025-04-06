import ExternalKeyboardListenerEmitter, {
  type KeyPressEvent,
} from 'react-native-external-keyboard-listener';
import {
  Text,
  View,
  StyleSheet,
  TextInput,
  Platform,
  Keyboard,
} from 'react-native';
import { useState, useEffect, useRef } from 'react';

export default function App() {
  //#region states
  const [isBLEKeyboardConnected, setIsBLEKeyboardConnected] = useState<boolean>();
  const [keyPress, setKeyPress] = useState<KeyPressEvent>();
  const [value, setValue] = useState('');
  //#region Refs
  const isBLEKeyboardConnectedRef = useRef(isBLEKeyboardConnected);
  
  //#region Effects
  useEffect(() => {
    // Check if the keyboard is connected
    ExternalKeyboardListenerEmitter.startListening((isConnect) => {
      setIsBLEKeyboardConnected(isConnect);
    });
    ExternalKeyboardListenerEmitter.checkKeyboardConnection().then(
      (isConnect) => {
        setIsBLEKeyboardConnected(isConnect);
      }
    );
    // Not show virtual keyboard when external keyboard is connected
    const kbwsSubs = Keyboard.addListener('keyboardWillShow', _ => {
      if (isBLEKeyboardConnectedRef.current) {
        Keyboard.dismiss();
      }
    })
    const kbdsSubs = Keyboard.addListener('keyboardDidShow', _ => {
      if (isBLEKeyboardConnectedRef.current) {
        Keyboard.dismiss();
      }
    })

    // Listen to key press events
    const kpSubs = ExternalKeyboardListenerEmitter.startKeyPressListener(
      (ev) => {
        if (ev.action === 'key_up') {
          setKeyPress(ev);
        }
      }
    );

    return () => {
      ExternalKeyboardListenerEmitter.stopListening();
      kbwsSubs?.remove();
      kbdsSubs?.remove();
      kpSubs?.remove();
    };
  }, []);
  useEffect(() => {
    isBLEKeyboardConnectedRef.current = isBLEKeyboardConnected;
    if (isBLEKeyboardConnected) {
      Keyboard.dismiss();
    }
  }, [isBLEKeyboardConnected]);
  useEffect(() => {
    // Dismiss the keyboard when the esc key is pressed
    if (
      keyPress?.pressedKey === 'UIKeyInputEscape' ||
      (Platform.OS === 'ios' && keyPress?.keyCode === 41) ||
      (Platform.OS === 'android' && keyPress?.keyCode === 111)
    ) {
      Keyboard.dismiss();
    }
  }, [keyPress]);

  return (
    <View style={styles.container}>
      <Text style={styles.txt}>BLE connection: {isBLEKeyboardConnected?.toString()}</Text>
      <Text style={styles.txt}>
        Key Press: {keyPress?.action} {keyPress?.keyCode} {keyPress?.pressedKey}
      </Text>

      <TextInput
        style={styles.input}
        showSoftInputOnFocus={!isBLEKeyboardConnected}
        placeholder="Type here"
        value={value}
        onChange={(e) => setValue(e.nativeEvent.text)}
        onKeyPress={(e) => {
          console.log('onKeyPress', e.nativeEvent);
        }}
      />
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
  },
  txt: {
    fontSize: 14,
    color: 'green',
  },
  input: {
    width: '100%',
    borderWidth: 1,
    borderColor: 'gray',
    minHeight: 20,
    padding: 5,
    color: 'green',
  },
});
