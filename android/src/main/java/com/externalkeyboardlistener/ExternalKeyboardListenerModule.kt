package com.externalkeyboardlistener

import android.view.KeyEvent
import com.facebook.react.bridge.*
import com.facebook.react.modules.core.DeviceEventManagerModule
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch

class ExternalKeyboardListenerModule(private val reactContext: ReactApplicationContext) :
  ReactContextBaseJavaModule(reactContext) {
  private val tag = "ExternalKeyboardListenerModule"
  private lateinit var keyboardMonitor: BluetoothKeyboardMonitor

  override fun getName(): String {
    return NAME
  }

  companion object {
    const val NAME = "ExternalKeyboardListener"
  }

  init {
    keyboardMonitor = BluetoothKeyboardMonitor(reactContext) { isConnected ->
      println("$tag KeyboardMonitor initial $isConnected")
      val params: WritableMap = Arguments.createMap().apply {
        putBoolean("isConnected", isConnected) // FIXED: Correct usage of putBoolean
      }
      sendEvent("KeyboardConnectionChanged", params)
    }
    /* forward activity event to controller */
    //  reactContext.addActivityEventListener(object : ActivityEventListener {
    //    override fun onActivityResult(activity: Activity, requestCode: Int, resultCode: Int, data: Intent?) {
    //      println("$tag activity result: requestCode: $requestCode, resultCode: $resultCode, data: $data")
    //    }
    //
    //    override fun onNewIntent(intent: Intent?) {
    //      // Handle new intent if necessary
    //    }
    //  })

    /* forward resume, pause, destroy to controller */
    reactContext.addLifecycleEventListener(object : LifecycleEventListener {
      override fun onHostResume() {
        reactContext?.currentActivity?.let { activity ->
          val originalCallback = activity.window.callback
          activity.window.callback = CustomWindowCallbackWrapper(originalCallback) { event ->
            handleKeyPress(event)
          }
        }
      }

      override fun onHostPause() {
        reactContext?.currentActivity?.let { activity ->
            //FIXME: is set to original needed?
//          activity.window.callback = (activity.window.callback as? CustomWindowCallbackWrapper)?.originalCallback
        }
      }

      override fun onHostDestroy() {
        reactContext?.removeLifecycleEventListener(this)
      }
    })
  }

  @ReactMethod
  fun startListening() {
      keyboardMonitor?.startListening()
      CoroutineScope(Dispatchers.Main).launch {
        val connected = keyboardMonitor?.isBluetoothKeyboardConnected() ?: false
        val params: WritableMap = Arguments.createMap().apply {
          putBoolean("isConnected", connected ?: false) // FIXED: Correct usage of putBoolean
        }
        sendEvent("KeyboardConnectionChanged", params)
      }
  }

  @ReactMethod
  fun stopListening() {
    try {
      keyboardMonitor?.stopListening()
    } catch (_: Exception) {}
  }

  @ReactMethod
  fun checkKeyboardConnection(promise: Promise) {
      CoroutineScope(Dispatchers.Main).launch {
          val connected = keyboardMonitor?.isBluetoothKeyboardConnected() ?: false
          promise.resolve(connected)
      }
  }


  @ReactMethod
  fun isBluetoothEnabled(promise: Promise) {
    try {
      promise.resolve(keyboardMonitor?.isBluetoothEnabled())
    } catch (_: Exception) {}
  }

  @ReactMethod
  fun enableBluetooth(promise: Promise) {
      CoroutineScope(Dispatchers.Main).launch {
          promise.resolve(keyboardMonitor?.enableBluetooth())
      }
  }

  @ReactMethod
  fun addListener(eventName: String?) {
    // Required for NativeEventEmitter
  }

  @ReactMethod
  fun removeListeners(count: Int?) {
    // Required for NativeEventEmitter
    stopListening()
  }

  // Example function to handle key down events
  fun handleKeyPress(event: KeyEvent) {
    val params: WritableMap = getJsEventParams(event)
    sendEvent("OnKeyPress", params)
  }

  private fun getJsEventParams(keyEvent: KeyEvent): WritableMap {
    val params: WritableMap = WritableNativeMap()

    if (keyEvent.action == KeyEvent.ACTION_MULTIPLE && keyEvent.keyCode == KeyEvent.KEYCODE_UNKNOWN) {
      val chars = keyEvent.characters
      if (chars != null) {
        params.putString("characters", chars)
      }
    }

    val pressedKey = keyEvent.unicodeChar.toChar()
    params.putInt("keyCode", keyEvent.keyCode)
    params.putInt("action", keyEvent.action)
    params.putString("pressedKey", pressedKey.toString())

    return params
  }

  private fun sendEvent(eventName: String, params: WritableMap?) {
      reactContext
          .getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter::class.java)
          .emit(eventName, params)
  }
}
