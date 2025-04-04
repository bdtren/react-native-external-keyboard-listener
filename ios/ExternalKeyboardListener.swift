import Foundation
import React
import UIKit

@objc(ExternalKeyboardListener)
class ExternalKeyboardListener: RCTEventEmitter {
  // Hold a shared instance so that other native code can post events to this module.
  static var shared: ExternalKeyboardListener?

  let monitor = BluetoothKeyboardMonitor()

  override init() {
    super.init()
    ExternalKeyboardListener.shared = self
    // Ensure we are on the main thread for UI-related operations
    DispatchQueue.main.async {
      guard let window = UIApplication.shared.delegate?.window ?? nil else { return }
      let keyListenerVC = KeyEventListenerViewController()
      // Add as a child so that it participates in the responder chain.
      window.rootViewController?.addChild(keyListenerVC)
      window.rootViewController?.view.addSubview(keyListenerVC.view)
      keyListenerVC.view.frame = .zero  // Keep it hidden.
      keyListenerVC.didMove(toParent: window.rootViewController)
      keyListenerVC.becomeFirstResponder()
    }
  }

  override static func requiresMainQueueSetup() -> Bool {
    return true
  }

  override func supportedEvents() -> [String]! {
    return ["KeyboardConnectionChanged", "OnKeyPress"]
  }

  @objc
  func startListening() {
    monitor.startListening(callback: { val in
      self.sendEvent(withName: "KeyboardConnectionChanged", body: ["isConnected": val])
    })
  }

  @objc
  func stopListening() {
    monitor.stopListening()
  }

  @objc
  func checkKeyboardConnection(
    _ resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock
  ) {
    let isConnected = monitor.isBluetoothKeyboardConnected()
    resolve(isConnected)
  }
  
  @objc
  func isBluetoothEnabled(
    _ resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock
  ) {
    let result = monitor.isBluetoothEnabled()
    resolve(result)
  }

  @objc
  func enableBluetooth(
    _ resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock
  ) {
    let result = monitor.openBluetoothSettings()
    resolve(result)
  }

  func handleKeyPress(keyCode: Int, action: Int, pressedKey: String) {
    self.sendEvent(
      withName: "OnKeyPress",
      body: [
        "keyCode": keyCode,
        "action": action,
        "pressedKey": pressedKey,
      ])
  }
}
