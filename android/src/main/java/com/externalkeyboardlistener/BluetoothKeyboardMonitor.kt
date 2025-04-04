package com.externalkeyboardlistener

import android.Manifest
import android.annotation.SuppressLint
import android.bluetooth.BluetoothAdapter
import android.bluetooth.BluetoothClass
import android.bluetooth.BluetoothDevice
import android.bluetooth.BluetoothManager
import android.bluetooth.BluetoothProfile.GATT
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Context.BLUETOOTH_SERVICE
import android.content.Intent
import android.content.IntentFilter
import android.content.pm.PackageManager
import android.os.Build
import android.view.inputmethod.InputMethodManager
import android.view.inputmethod.InputMethodSubtype
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext

@SuppressLint("MissingPermission")
class BluetoothKeyboardMonitor(private val context: Context, private val callback: (Boolean) -> Unit) {
    private val tag = "BLE_KEYBOARD_MONITOR"
    private var bluetoothReceiver: BroadcastReceiver? = null

    // ✅ Method 1: Check if a Bluetooth keyboard is already connected
    suspend fun isBluetoothKeyboardConnected(): Boolean = withContext(Dispatchers.IO) {
        var isConnected = false
        if (context.checkSelfPermission(Manifest.permission.BLUETOOTH_CONNECT) ==
          PackageManager.PERMISSION_GRANTED) {
          val btManager = context.getSystemService(BLUETOOTH_SERVICE) as BluetoothManager
          val connectedDevices = btManager.getConnectedDevices(GATT)

          for (device in connectedDevices) {
            if (isBLEKeyboard(device)) {
              isConnected = true
              break
            }
          }
        }

        // ✅ Additional check: If on-screen keyboard is hidden, external keyboard might be active
        val inputMethodManager = context.getSystemService(Context.INPUT_METHOD_SERVICE) as InputMethodManager
        val activeInputMethod: InputMethodSubtype? = inputMethodManager.currentInputMethodSubtype
        return@withContext isConnected || (activeInputMethod?.isAuxiliary ?: false)
    }

    // ✅ Method 2: Listen for Bluetooth keyboard connection/disconnection
    fun startListening() {
      println("$tag Start listening")

      val filter = IntentFilter().apply {
            addAction(BluetoothDevice.ACTION_ACL_CONNECTED)
            addAction(BluetoothDevice.ACTION_ACL_DISCONNECTED)
        }

        bluetoothReceiver = object : BroadcastReceiver() {
            override fun onReceive(context: Context?, intent: Intent?) {
              if (context?.checkSelfPermission(Manifest.permission.BLUETOOTH_CONNECT) != PackageManager.PERMISSION_GRANTED) {
                callback(false)
                return
              }
              CoroutineScope(Dispatchers.IO).launch {
                when (intent?.action) {
                  BluetoothDevice.ACTION_ACL_CONNECTED -> {
                    val device = intent.getParcelableExtra<BluetoothDevice>(BluetoothDevice.EXTRA_DEVICE)
                    if (isBLEKeyboard(device)) {
                      callback(true) // Bluetooth keyboard connected
                    }
                  }
                  BluetoothDevice.ACTION_ACL_DISCONNECTED -> {

                    val device = intent.getParcelableExtra<BluetoothDevice>(BluetoothDevice.EXTRA_DEVICE)
                    if (isBLEKeyboard(device)) {
                      val connected = isBluetoothKeyboardConnected() ?: false;

                      callback(connected) // Bluetooth keyboard disconnected
                    }
                  }
                }
              }

            }
        }
        context.registerReceiver(bluetoothReceiver, filter)
    }

    fun stopListening() {
        bluetoothReceiver?.let {
            context.unregisterReceiver(it)
        }
    }

  fun isBluetoothEnabled(): Boolean {
    val bluetoothAdapter: BluetoothAdapter? = BluetoothAdapter.getDefaultAdapter()
    return bluetoothAdapter != null && bluetoothAdapter.isEnabled
  }

  fun enableBluetooth() {
    val bluetoothAdapter: BluetoothAdapter? = BluetoothAdapter.getDefaultAdapter()
    if (bluetoothAdapter != null && !bluetoothAdapter.isEnabled) {
      if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
        if (context.checkSelfPermission(Manifest.permission.BLUETOOTH_CONNECT) == PackageManager.PERMISSION_GRANTED) {
          val enableBtIntent = Intent(BluetoothAdapter.ACTION_REQUEST_ENABLE)
          context.startActivity(enableBtIntent)
        }
      } else if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
        // Requires BLUETOOTH_CONNECT permission (Android 12+)
        if (context.checkSelfPermission(Manifest.permission.BLUETOOTH_CONNECT) == PackageManager.PERMISSION_GRANTED) {
          bluetoothAdapter.enable() // Enable Bluetooth directly
        }
      } else {
        bluetoothAdapter.enable() // Works for Android 11 and below
      }
    }
  }

    @SuppressLint("MissingPermission")
    private fun isBLEKeyboard(device: BluetoothDevice?): Boolean {
      return device?.name?.lowercase()?.contains("keyboard") == true ||
        (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU && device?.bluetoothClass?.deviceClass == BluetoothClass.Device.PERIPHERAL_KEYBOARD) ||
        arrayOf(
          "0000180f-0000-1000-8000-00805f9b34fb",
          "00001812-0000-1000-8000-00805f9b34fb"
        ).any { device?.uuids?.toString()?.contains(it) == true }
    }
}
