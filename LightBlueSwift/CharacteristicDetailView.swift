//
//  CharacteristicDetailView.swift
//  LightBlueSwift
//
//  Created by user on 2024/10/17.
//

import SwiftUI
import CoreBluetooth

class CharacteristicViewModel: NSObject, ObservableObject, CBPeripheralDelegate {
    @Published var value: String = "N/A"
    let characteristic: CBCharacteristic
    
    init(characteristic: CBCharacteristic) {
        self.characteristic = characteristic
        super.init()
        characteristic.service?.peripheral?.delegate = self
    }
    
    func readValue() {
        characteristic.service?.peripheral?.readValue(for: characteristic)
    }
    
    func toggleNotification() {
        characteristic.service?.peripheral?.setNotifyValue(!characteristic.isNotifying, for: characteristic)
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if let value = characteristic.value {
            self.value = String(data: value, encoding: .utf8) ?? "Unable to decode"
        }
    }
}

struct CharacteristicDetailView: View {
    @StateObject private var viewModel: CharacteristicViewModel
    @Environment(\.presentationMode) var presentationMode
    
    init(characteristic: CBCharacteristic) {
        _viewModel = StateObject(wrappedValue: CharacteristicViewModel(characteristic: characteristic))
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Characteristic Info")) {
                    Text("UUID: \(viewModel.characteristic.uuid.uuidString)")
                    Text("Properties: \(characteristicProperties)")
                }
                
                Section(header: Text("Value")) {
                    Text(viewModel.value)
                    if viewModel.characteristic.properties.contains(.read) {
                        Button("Read Value") {
                            viewModel.readValue()
                        }
                    }
                    if viewModel.characteristic.properties.contains(.write) {
                        Button("Write Value") {
                            // Implement write functionality
                        }
                    }
                    if viewModel.characteristic.properties.contains(.notify) {
                        Button(viewModel.characteristic.isNotifying ? "Unsubscribe" : "Subscribe") {
                            viewModel.toggleNotification()
                        }
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(leading: Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                Text("Done")
            })
        }
    }
    
    private var characteristicProperties: String {
        var properties: [String] = []
        if viewModel.characteristic.properties.contains(.read) { properties.append("Read") }
        if viewModel.characteristic.properties.contains(.write) { properties.append("Write") }
        if viewModel.characteristic.properties.contains(.notify) { properties.append("Notify") }
        return properties.joined(separator: ", ")
    }
}
