import {
  NativeModules,
  Platform,
  NativeEventEmitter,
  PermissionsAndroid,
  type EmitterSubscription,
} from 'react-native';
import { handleActionName, type KeyPressEvent } from './types/index.types';
export * from './types/index.types';

const LINKING_ERROR =
  `The package 'react-native-external-keyboard-listener' doesn't seem to be linked. Make sure: \n\n` +
  Platform.select({ ios: "- You have run 'pod install'\n", default: '' }) +
  '- You rebuilt the app after installing the package\n' +
  '- You are not using Expo Go\n';

const ExternalKeyboardListener = NativeModules.ExternalKeyboardListener
  ? NativeModules.ExternalKeyboardListener
  : new Proxy(
      {},
      {
        get() {
          throw new Error(LINKING_ERROR);
        },
      }
    );

const externalKeyboardListenerEmitter = new NativeEventEmitter(
  ExternalKeyboardListener
);

var bluetoothKeyboardListener: EmitterSubscription | undefined;

const startListening = async (env: (isConnect: boolean) => any) => {
  //FIXME: for now not do anything if the bluetooth is not enabled
  const isBleEnabled = await isBluetoothEnabled();
  if (!isBleEnabled) {
    return;
  }

  const permissionGranted = await requestBluetoothPermission();
  if (permissionGranted) {
    ExternalKeyboardListener.startListening();
    bluetoothKeyboardListener?.remove();
    bluetoothKeyboardListener = externalKeyboardListenerEmitter.addListener(
      'KeyboardConnectionChanged',
      (event) => {
        env(event.isConnected);
      }
    );
  }
};

const stopListening = async () => {
  bluetoothKeyboardListener?.remove();
  await ExternalKeyboardListener.stopListening();
};

const isBluetoothEnabled = async (): Promise<boolean> => {
  return await ExternalKeyboardListener.isBluetoothEnabled();
};

const enableBluetooth = async () => {
  await ExternalKeyboardListener.enableBluetooth();
};

const checkKeyboardConnection = async () => {
  try {
    const permissionGranted = await requestBluetoothPermission();
    if (!permissionGranted) {
      return false;
    }

    const isConnected =
      await ExternalKeyboardListener.checkKeyboardConnection();
    return isConnected;
  } catch (error) {
    console.error(error);
    return false;
  }
};

const requestBluetoothPermission = async () => {
  if (Platform.OS === 'ios') {
    return true;
  }
  if (Platform.OS === 'android') {
    const apiLevel = parseInt(Platform.Version.toString(), 10);

    if (apiLevel < 31 && PermissionsAndroid.PERMISSIONS.ACCESS_FINE_LOCATION) {
      const granted = await PermissionsAndroid.request(
        PermissionsAndroid.PERMISSIONS.ACCESS_FINE_LOCATION
      );
      return granted === PermissionsAndroid.RESULTS.GRANTED;
    }
    if (
      PermissionsAndroid.PERMISSIONS.BLUETOOTH_SCAN &&
      PermissionsAndroid.PERMISSIONS.BLUETOOTH_CONNECT
    ) {
      const result = await PermissionsAndroid.requestMultiple([
        PermissionsAndroid.PERMISSIONS.BLUETOOTH_SCAN,
        PermissionsAndroid.PERMISSIONS.BLUETOOTH_CONNECT,
      ]);

      return (
        result['android.permission.BLUETOOTH_CONNECT'] ===
          PermissionsAndroid.RESULTS.GRANTED &&
        result['android.permission.BLUETOOTH_SCAN'] ===
          PermissionsAndroid.RESULTS.GRANTED
      );
    }
  }

  return false;
};


const startKeyPressListener = (env: (event: KeyPressEvent) => any): EmitterSubscription => {
  return externalKeyboardListenerEmitter.addListener(
    'OnKeyPress',
    (event) => {
      env({
        ...event,
        action: handleActionName(event.action),
      });
    }
  );
}

const ExternalKeyboardListenerEmitter = {
  startListening,
  stopListening,
  checkKeyboardConnection,
  isBluetoothEnabled,
  enableBluetooth,
  requestBluetoothPermission,
  startKeyPressListener
};

export default ExternalKeyboardListenerEmitter;
