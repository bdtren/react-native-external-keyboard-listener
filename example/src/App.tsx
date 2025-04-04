import ExternalKeyboardListenerEmitter, { type KeyPressEvent } from 'react-native-external-keyboard-listener';
import { Text, View, StyleSheet, TextInput } from 'react-native';
import { useState, useEffect } from 'react';

export default function App() {
  const [result, setResult] = useState<boolean>();
  const [keyPress, setKeyPress] = useState<KeyPressEvent>();
  const [value, setValue] = useState('');

  useEffect(() => {
    ExternalKeyboardListenerEmitter.startListening(isConnect => {
      setResult(isConnect);
    })
    const kpSubs = ExternalKeyboardListenerEmitter.startKeyPressListener(ev => {
      if (ev.action === 'key_up') {
        setKeyPress(ev);
      }
    })
    
    ExternalKeyboardListenerEmitter.checkKeyboardConnection().then(isConnect => {
      setResult(isConnect);
    })

    return () => {
      ExternalKeyboardListenerEmitter.stopListening();
      kpSubs?.remove();
    };
  }, []);

  return (
    <View style={styles.container}>
      <Text style={styles.txt}>BLE connection: {result?.toString()}</Text>
      <Text style={styles.txt}>Key Press: {keyPress?.action} {keyPress?.keyCode} {keyPress?.pressedKey}</Text>

      <TextInput
        style={styles.input}
        placeholder="Type here"
        value={value}
        onChange={(e) => setValue(e.nativeEvent.text)}
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
