package com.externalkeyboardlistener

import android.view.KeyEvent
import com.facebook.react.bridge.*
import com.facebook.react.modules.core.DeviceEventManagerModule

class KeyboardKeyEventMonitor(private val reactContext: ReactApplicationContext) {

  private fun sendKeyEvent(eventName: String, keyCode: Int) {
    reactContext
      .getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter::class.java)
      .emit(eventName, keyCode)
  }

  fun handleKeyDown(keyCode: Int) {
    sendKeyEvent("onKeyDown", keyCode)
  }

  fun handleKeyUp(keyCode: Int) {
    sendKeyEvent("onKeyUp", keyCode)
  }
}
