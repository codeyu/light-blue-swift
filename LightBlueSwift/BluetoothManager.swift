//
//  BluetoothManager.swift
//  LightBlueSwift
//
//  Created by user on 2024/10/17.
//

import CoreBluetooth

class BluetoothManager: NSObject, ObservableObject {
    @Published var discoveredPeripherals: [(peripheral: CBPeripheral, rssi: NSNumber)] = []
    @Published var connectedPeripheral: CBPeripheral?
    var advertisementData: [UUID: [String: Any]] = [:]
    var centralManager: CBCentralManager?
    var connectionCallback: ((Bool) -> Void)?

    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }

    func startScanning() {
        guard centralManager?.state == .poweredOn else { return }
        centralManager?.scanForPeripherals(withServices: nil, options: nil)
    }

    func stopScanning() {
        centralManager?.stopScan()
    }

    func connect(to peripheral: CBPeripheral, completion: @escaping (Bool) -> Void) {
        guard centralManager?.state == .poweredOn else {
            completion(false)
            return
        }
        
        connectionCallback = completion
        centralManager?.connect(peripheral, options: nil)
    }

    func disconnect(_ peripheral: CBPeripheral) {
        centralManager?.cancelPeripheralConnection(peripheral)
    }

    func resetState() {
        stopScanning()
        if let connectedPeripheral = connectedPeripheral {
            disconnect(connectedPeripheral)
        }
        discoveredPeripherals.removeAll()
        connectedPeripheral = nil
        advertisementData.removeAll()
        connectionCallback = nil
    }
}

extension BluetoothManager: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            startScanning()
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if !discoveredPeripherals.contains(where: { $0.peripheral.identifier == peripheral.identifier }) {
            discoveredPeripherals.append((peripheral: peripheral, rssi: RSSI))
            self.advertisementData[peripheral.identifier] = advertisementData
            objectWillChange.send()
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        DispatchQueue.main.async {
            self.connectedPeripheral = peripheral
            self.connectionCallback?(true)
            self.connectionCallback = nil
        }
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        DispatchQueue.main.async {
            self.connectionCallback?(false)
            self.connectionCallback = nil
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        DispatchQueue.main.async {
            if peripheral == self.connectedPeripheral {
                self.connectedPeripheral = nil
            }
        }
    }
}
