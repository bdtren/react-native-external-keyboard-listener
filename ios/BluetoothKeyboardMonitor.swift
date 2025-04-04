import CoreBluetooth

class BluetoothKeyboardMonitor: NSObject, CBCentralManagerDelegate {
    private var centralManager: CBCentralManager!
    private var discoveredPeripherals: [CBPeripheral] = []
    private var keyboardConnectedCallback: ((Bool) -> Void)?
    private var keyboardUUIDs = [CBUUID(string: "180f"), CBUUID(string: "1812")]
    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }

    // Method 1: Check if a Bluetooth keyboard is already connected
    func isBluetoothKeyboardConnected() -> Bool {
        if centralManager.state != .poweredOn {
            return false
        }
        // Retrieve connected peripherals advertising the HID service.
        guard
            let peripherals = centralManager.retrieveConnectedPeripherals(
                withServices: keyboardUUIDs) as [CBPeripheral]?
        else {
            return false
        }

        if peripherals.count == 0 {
            return false
        }

        // Check for a peripheral that is connected and seems like a keyboard.
        let keyboardConnected = peripherals.contains { peripheral in
            let nameContainsKeyboard = peripheral.name?.lowercased().contains("keyboard") == true
            let descriptionContainsKeyboard = peripheral.description.lowercased().contains(
                "keyboard")
            // uuids restriction already done in retrieveConnectedPeripherals
            let servicesContainKeyboard = true
            //FIXME: this always true
            return nameContainsKeyboard || descriptionContainsKeyboard || servicesContainKeyboard
        }

        return keyboardConnected
    }

    // Method 2: Listen for Bluetooth keyboard connection/disconnection
    func startListening(callback: @escaping (Bool) -> Void) {
        keyboardConnectedCallback = callback
        scanBluetooth()
    }

    func stopListening() {
        centralManager.stopScan()
        keyboardConnectedCallback = nil
    }
  
    func isBluetoothEnabled() -> Bool {
        return centralManager.state == .poweredOn
    }

    func openBluetoothSettings() -> Bool {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
            return true
        }
        return false
    }

    // CBCentralManagerDelegate methods
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            centralManager.scanForPeripherals(withServices: keyboardUUIDs, options: nil)
        } else {
            centralManager.stopScan()
        }
    }

    func centralManager(
        _ central: CBCentralManager, didDiscover peripheral: CBPeripheral,
        advertisementData: [String: Any], rssi RSSI: NSNumber
    ) {
        if discoveredPeripherals.contains(peripheral) != true {
            discoveredPeripherals.append(peripheral as CBPeripheral)
        }
        self.centralManager.connect(peripheral as CBPeripheral, options: nil)
        // Reset scanner
        self.centralManager.stopScan()
        scanBluetooth()

        DispatchQueue.main.asyncAfter(deadline: .now() + 6) {  //Delay 6s for complicated devices connection
            let val = self.isBluetoothKeyboardConnected()
            self.keyboardConnectedCallback?(val)

            // Stop scan to save energy when successfully connect
            if !val && peripheral.state != .connected {
                self.centralManager.stopScan()

            }
        }
    }

    func centralManager(
        _ central: CBCentralManager, didConnect peripheral: CBPeripheral
    ) {
        isBLEKeyboard(peripheral: peripheral) { isKeyboard in
            if isKeyboard {
                self.keyboardConnectedCallback?(true)
            }
        }
    }

    func centralManager(
        _ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?
    ) {
        if discoveredPeripherals.contains(peripheral) {
            discoveredPeripherals = discoveredPeripherals.filter({ it in
                it.identifier != peripheral.identifier
            })
            let val = isBluetoothKeyboardConnected()
            keyboardConnectedCallback?(val)

            // Start scan again if no more device connected
            if !val {
                scanBluetooth()
            }
        }
    }

    func scanBluetooth() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            if self.centralManager.state == .poweredOn {
                NSLog("Bluetooth is powered on. Scanning for keyboard...")
                self.centralManager.scanForPeripherals(
                    withServices: self.keyboardUUIDs, options: nil)
            }
        }
    }

    func isBLEKeyboard(peripheral: CBPeripheral, completion: @escaping (Bool) -> Void) {
        Task {
            do {
                if peripheral.name?.lowercased().contains("keyboard") ?? false
                    || peripheral.description.lowercased().contains("keyboard")
                {
                    return completion(true)
                }

                let services = try await peripheral.discoverServicesAsync(keyboardUUIDs)
                return completion(services.count > 0)
            } catch {
                NSLog("Error: \(error)")
            }
            return completion(false)
        }
    }
}
