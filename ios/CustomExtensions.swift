import CoreBluetooth

extension CBPeripheral {
    func discoverServicesAsync(_ serviceUUIDs: [CBUUID]?) async throws -> [CBService] {
        return try await withCheckedThrowingContinuation { continuation in
            self.discoverServices(serviceUUIDs)
            self.delegate = PeripheralDelegate.shared
            PeripheralDelegate.shared.onServicesDiscovered = { services, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else if let services = services {
                    continuation.resume(returning: services)
                } else {
                    continuation.resume(
                        throwing: NSError(domain: "CBPeripheralError", code: -1, userInfo: nil))
                }
            }
        }
    }
}

class PeripheralDelegate: NSObject, CBPeripheralDelegate {
    static let shared = PeripheralDelegate()
    var onServicesDiscovered: (([CBService]?, Error?) -> Void)?

    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        onServicesDiscovered?(peripheral.services, error)
    }
}
