//
//  ServiceDetailView.swift
//  LightBlueSwift
//
//  Created by user on 2024/10/17.
//

import SwiftUI
import CoreBluetooth

class ServiceViewModel: NSObject, ObservableObject, CBPeripheralDelegate {
    @Published var characteristics: [CBCharacteristic] = []
    let service: CBService
    
    init(service: CBService) {
        self.service = service
        super.init()
        service.peripheral?.delegate = self
    }
    
    func discoverCharacteristics() {
        service.peripheral?.discoverCharacteristics(nil, for: service)
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let characteristics = service.characteristics {
            self.characteristics = characteristics
        }
    }
}

struct ServiceDetailView: View {
    @StateObject private var viewModel: ServiceViewModel
    
    init(service: CBService) {
        _viewModel = StateObject(wrappedValue: ServiceViewModel(service: service))
    }
    
    var body: some View {
        List {
            ForEach(viewModel.characteristics, id: \.uuid) { characteristic in
                NavigationLink(destination: CharacteristicDetailView(characteristic: characteristic)) {
                    VStack(alignment: .leading) {
                        Text(characteristic.uuid.uuidString)
                        Text(characteristicProperties(characteristic))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .navigationTitle("Service Details")
        .onAppear {
            viewModel.discoverCharacteristics()
        }
    }
    
    private func characteristicProperties(_ characteristic: CBCharacteristic) -> String {
        var properties: [String] = []
        if characteristic.properties.contains(.read) { properties.append("Read") }
        if characteristic.properties.contains(.write) { properties.append("Write") }
        if characteristic.properties.contains(.notify) { properties.append("Notify") }
        return properties.joined(separator: ", ")
    }
}
