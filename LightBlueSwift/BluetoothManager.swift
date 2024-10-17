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
    
    private var centralManager: CBCentralManager?
    private var connectionTimer: Timer?
    private var connectionCallback: ((Bool) -> Void)?
    
    override init() {
        super.init()
        self.centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    func startScanning() {
        centralManager?.scanForPeripherals(withServices: nil, options: nil)
    }
    
    func stopScanning() {
        centralManager?.stopScan()
    }
    
    func connect(to peripheral: CBPeripheral, completion: @escaping (Bool) -> Void) {
        connectionCallback = completion
        centralManager?.connect(peripheral, options: nil)
        
        // Set a timer for 10 seconds
        connectionTimer = Timer.scheduledTimer(withTimeInterval: 10.0, repeats: false) { [weak self] _ in
            self?.cancelConnection(peripheral)
            self?.connectionCallback?(false)
        }
    }
    
    func cancelConnection(_ peripheral: CBPeripheral) {
        centralManager?.cancelPeripheralConnection(peripheral)
        connectionTimer?.invalidate()
        connectionTimer = nil
    }
    
    func disconnect(_ peripheral: CBPeripheral) {
        centralManager?.cancelPeripheralConnection(peripheral)
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
        connectedPeripheral = peripheral
        connectionTimer?.invalidate()
        connectionTimer = nil
        connectionCallback?(true)
        stopScanning()
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        connectionTimer?.invalidate()
        connectionTimer = nil
        connectionCallback?(false)
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        if peripheral == connectedPeripheral {
            connectedPeripheral = nil
        }
    }
}
