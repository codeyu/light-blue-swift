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
            DispatchQueue.main.async {
                self.services = services
            }
        }
    }
}

struct PeripheralDetailView: View {
    @StateObject private var viewModel: PeripheralViewModel
    @ObservedObject var bluetoothManager: BluetoothManager
    @Binding var isPresented: Bool
    
    init(peripheral: CBPeripheral, bluetoothManager: BluetoothManager, isPresented: Binding<Bool>) {
        _viewModel = StateObject(wrappedValue: PeripheralViewModel(peripheral: peripheral))
        self.bluetoothManager = bluetoothManager
        self._isPresented = isPresented
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
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: Button(action: {
            bluetoothManager.disconnect(viewModel.peripheral)
            isPresented = false
        }) {
            HStack {
                Image(systemName: "chevron.left")
                Text("Back")
            }
        })
        .onAppear {
            print("PeripheralDetailView appeared")
            viewModel.discoverServices()
        }
    }
}
