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
    let peripheral: CBPeripheral
    
    init(peripheral: CBPeripheral) {
        self.peripheral = peripheral
        super.init()
        self.peripheral.delegate = self
    }
    
    func discoverServices() {
        peripheral.discoverServices(nil)
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let services = peripheral.services {
            self.services = services
        }
    }
}

struct PeripheralDetailView: View {
    @StateObject private var viewModel: PeripheralViewModel
    
    init(peripheral: CBPeripheral) {
        _viewModel = StateObject(wrappedValue: PeripheralViewModel(peripheral: peripheral))
    }
    
    var body: some View {
        List {
            Section(header: Text("Device Info")) {
                Text("Name: \(viewModel.peripheral.name ?? "Unknown")")
                Text("UUID: \(viewModel.peripheral.identifier.uuidString)")
            }
            
            Section(header: Text("Services")) {
                ForEach(viewModel.services, id: \.uuid) { service in
                    NavigationLink(destination: ServiceDetailView(service: service)) {
                        Text(service.uuid.uuidString)
                    }
                }
            }
        }
        .navigationTitle("Device Details")
        .onAppear {
            viewModel.discoverServices()
        }
    }
}
