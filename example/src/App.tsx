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
  const [result, setResult] = useState<boolean>();
  const [keyPress, setKeyPress] = useState<KeyPressEvent>();
  const [value, setValue] = useState('');
  //#region Refs
  const resultRef = useRef(result);
  //#region Effects
  useEffect(() => {
    // Check if the keyboard is connected
    ExternalKeyboardListenerEmitter.startListening((isConnect) => {
      setResult(isConnect);
    });
    ExternalKeyboardListenerEmitter.checkKeyboardConnection().then(
      (isConnect) => {
        setResult(isConnect);
      }
    );
    // Not show virtual keyboard when external keyboard is connected
    Keyboard.addListener('keyboardWillShow', e => {
      if (resultRef.current) {
        Keyboard.dismiss();
      }
    })
    Keyboard.addListener('keyboardDidShow', e => {
      if (resultRef.current) {
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
      kpSubs?.remove();
    };
  }, []);
  useEffect(() => {
    resultRef.current = result;
    if (result) {
      Keyboard.dismiss();
    }
  }, [result]);
  useEffect(() => {
    // Dismiss the keyboard when the esc key is pressed
    if (
      keyPress?.pressedKey === 'UIKeyInputEscape' ||
      (Platform.OS === 'ios' && keyPress?.keyCode === 85) ||
      (Platform.OS === 'android' && keyPress?.keyCode === 111)
    ) {
      Keyboard.dismiss();
    }
  }, [keyPress]);

  return (
    <View style={styles.container}>
      <Text style={styles.txt}>BLE connection: {result?.toString()}</Text>
      <Text style={styles.txt}>
        Key Press: {keyPress?.action} {keyPress?.keyCode} {keyPress?.pressedKey}
      </Text>

      <TextInput
        style={styles.input}
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
