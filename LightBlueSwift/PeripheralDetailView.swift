//
//  PeripheralDetailView.swift
//  LightBlueSwift
//
//  Created by user on 2024/10/17.
//

import SwiftUI
import CoreBluetooth

class PeripheralViewModel: NSObject, ObservableObject, CBPeripheralDelegate {
    @Published var services: [CBService] = []
    @Published var advertisementData: [String: Any] = [:]
    @Published var characteristics: [CBUUID: [CBCharacteristic]] = [:]
    let peripheral: CBPeripheral
    
    init(peripheral: CBPeripheral, advertisementData: [String: Any]) {
        self.peripheral = peripheral
        self.advertisementData = advertisementData
        super.init()
        self.peripheral.delegate = self
    }
    
    func discoverServices() {
        peripheral.discoverServices(nil)
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let services = peripheral.services {
            DispatchQueue.main.async {
                self.services = services
                for service in services {
                    peripheral.discoverCharacteristics(nil, for: service)
                }
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        DispatchQueue.main.async {
            if let characteristics = service.characteristics {
                self.characteristics[service.uuid] = characteristics
            }
        }
    }
}

struct PeripheralDetailView: View {
    @StateObject private var viewModel: PeripheralViewModel
    @ObservedObject var bluetoothManager: BluetoothManager
    let dismiss: () -> Void
    
    @State private var isAdvertisementDataExpanded = false
    @State private var expandedServices: Set<CBUUID> = []
    @State private var selectedCharacteristic: CBCharacteristic?
    @State private var isCharacteristicDetailPresented = false
    
    init(peripheral: CBPeripheral, bluetoothManager: BluetoothManager, dismiss: @escaping () -> Void) {
        _viewModel = StateObject(wrappedValue: PeripheralViewModel(peripheral: peripheral, advertisementData: bluetoothManager.advertisementData[peripheral.identifier] ?? [:]))
        self.bluetoothManager = bluetoothManager
        self.dismiss = dismiss
    }
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Device Info")) {
                    Text("Name: \(viewModel.peripheral.name ?? "Unknown")")
                    Text("UUID: \(viewModel.peripheral.identifier.uuidString)")
                }
                
                Section {
                    DisclosureGroup(
                        isExpanded: $isAdvertisementDataExpanded,
                        content: {
                            ForEach(Array(viewModel.advertisementData.keys), id: \.self) { key in
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(key)
                                        .font(.headline)
                                    Text("\(String(describing: viewModel.advertisementData[key]!))")
                                        .font(.subheadline)
                                }
                                .padding(.vertical, 4)
                            }
                        },
                        label: {
                            Text("View Advertisement Data")
                        }
                    )
                }
                
                Section(header: Text("Services")) {
                    ForEach(viewModel.services, id: \.uuid) { service in
                        DisclosureGroup(
                            isExpanded: Binding(
                                get: { expandedServices.contains(service.uuid) },
                                set: { newValue in
                                    if newValue {
                                        expandedServices.insert(service.uuid)
                                    } else {
                                        expandedServices.remove(service.uuid)
                                    }
                                }
                            ),
                            content: {
                                ForEach(viewModel.characteristics[service.uuid] ?? [], id: \.uuid) { characteristic in
                                    Button(action: {
                                        selectedCharacteristic = characteristic
                                        isCharacteristicDetailPresented = true
                                    }) {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(characteristic.uuid.uuidString)
                                                .font(.headline)
                                            Text("Properties: \(characteristicPropertiesString(characteristic))")
                                                .font(.subheadline)
                                        }
                                        .padding(.vertical, 4)
                                    }
                                }
                            },
                            label: {
                                Text(service.uuid.uuidString)
                            }
                        )
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Device Details")
                        .font(.headline)
                        .foregroundColor(.white)
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        bluetoothManager.disconnect(viewModel.peripheral)
                        dismiss()
                    }) {
                        HStack {
                            Image(systemName: "chevron.left")
                            Text("Disconnect")
                        }
                        .foregroundColor(.white)
                    }
                }
            }
        }
        .sheet(isPresented: $isCharacteristicDetailPresented) {
            if let characteristic = selectedCharacteristic {
                CharacteristicDetailView(characteristic: characteristic)
            }
        }
        .onAppear {
            viewModel.discoverServices()
        }
    }
    
    func characteristicPropertiesString(_ characteristic: CBCharacteristic) -> String {
        var properties: [String] = []
        if characteristic.properties.contains(.read) { properties.append("Read") }
        if characteristic.properties.contains(.write) { properties.append("Write") }
        if characteristic.properties.contains(.notify) { properties.append("Notify") }
        if characteristic.properties.contains(.indicate) { properties.append("Indicate") }
        return properties.joined(separator: ", ")
    }
}
