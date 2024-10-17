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
    @Published var valueHistory: [(Date, String)] = []
    @Published var writeValue: String = ""
    let characteristic: CBCharacteristic
    private let maxHistoryCount = 10
    
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
            let newValue = String(data: value, encoding: .utf8) ?? "Unable to decode"
            DispatchQueue.main.async {
                self.value = newValue
                self.valueHistory.insert((Date(), newValue), at: 0)
                if self.valueHistory.count > self.maxHistoryCount {
                    self.valueHistory.removeLast()
                }
            }
        }
    }
    
    func clearValueHistory() {
        self.valueHistory.removeAll()
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        DispatchQueue.main.async {
            self.isNotifying = characteristic.isNotifying
        }
    }
    
    func writeCharacteristic() {
        guard let data = writeValue.data(using: .utf8) else { return }
        let writeType: CBCharacteristicWriteType = characteristic.properties.contains(.writeWithoutResponse) ? .withoutResponse : .withResponse
        characteristic.service?.peripheral?.writeValue(data, for: characteristic, type: writeType)
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
                }
                if viewModel.characteristic.properties.contains(.read) {
                    Section(header: Text("READ")) {
                        Button("Read") {
                            viewModel.readValue()
                        }
                        Text(viewModel.value)
                    }
                }
                if viewModel.characteristic.properties.contains(.write) || viewModel.characteristic.properties.contains(.writeWithoutResponse) {
                    Section(header: Text("WRITE")) {
                        HStack {
                            TextField("Enter value", text: $viewModel.writeValue)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            Button("Write") {
                                viewModel.writeCharacteristic()
                            }
                        }
                        Text("Write Type: \(writeTypeString)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                if viewModel.characteristic.properties.contains(.notify) {
                    Section(header: Text("NOTIFY")) {
                        HStack {
                            Button(viewModel.isNotifying ? "Unsubscribe" : "Subscribe") {
                                viewModel.toggleNotification()
                            }
                            Spacer()
                            Button("Clear") {
                                viewModel.clearValueHistory()
                            }
                        }
                        ForEach(viewModel.valueHistory, id: \.0) { timestamp, value in
                            HStack(alignment: .bottom) {
                                Text(value)
                                    .font(.body)
                                    .foregroundColor(.primary)
                                    .truncationMode(.tail)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                                Text(formatDate(timestamp))
                                    .font(.caption2)
                                    .foregroundColor(Color.gray.opacity(0.7))
                            }
                            .padding(.vertical, 8)
                            .padding(.horizontal, 10)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
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
    
    private var writeTypeString: String {
        if viewModel.characteristic.properties.contains(.write) && viewModel.characteristic.properties.contains(.writeWithoutResponse) {
            return "With or Without Response"
        } else if viewModel.characteristic.properties.contains(.write) {
            return "With Response"
        } else if viewModel.characteristic.properties.contains(.writeWithoutResponse) {
            return "Without Response"
        } else {
            return "Not Writable"
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss.SSS"
        return formatter.string(from: date)
    }
}
