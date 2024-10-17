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
    @Published var isNotifying: Bool
    let characteristic: CBCharacteristic
    
    init(characteristic: CBCharacteristic) {
        self.characteristic = characteristic
        self.isNotifying = characteristic.isNotifying
        super.init()
        characteristic.service?.peripheral?.delegate = self
    }
    
    func readValue() {
        characteristic.service?.peripheral?.readValue(for: characteristic)
    }
    
    func toggleNotification() {
        let newValue = !isNotifying
        characteristic.service?.peripheral?.setNotifyValue(newValue, for: characteristic)
        // 立即更新 isNotifying 状态
        DispatchQueue.main.async {
            self.isNotifying = newValue
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if let value = characteristic.value {
            DispatchQueue.main.async {
                self.value = String(data: value, encoding: .utf8) ?? "Unable to decode"
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        DispatchQueue.main.async {
            self.isNotifying = characteristic.isNotifying
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
                        Button(viewModel.isNotifying ? "Unsubscribe" : "Subscribe") {
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
