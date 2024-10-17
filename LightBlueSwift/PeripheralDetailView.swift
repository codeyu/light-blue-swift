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
            }
        }
    }
}

struct PeripheralDetailView: View {
    @StateObject private var viewModel: PeripheralViewModel
    @ObservedObject var bluetoothManager: BluetoothManager
    @Binding var isPresented: Bool
    
    init(peripheral: CBPeripheral, bluetoothManager: BluetoothManager, isPresented: Binding<Bool>) {
        _viewModel = StateObject(wrappedValue: PeripheralViewModel(peripheral: peripheral, advertisementData: bluetoothManager.advertisementData[peripheral.identifier] ?? [:]))
        self.bluetoothManager = bluetoothManager
        self._isPresented = isPresented
    }
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Device Info")) {
                    Text("Name: \(viewModel.peripheral.name ?? "Unknown")")
                    Text("UUID: \(viewModel.peripheral.identifier.uuidString)")
                }
                
                Section(header: Text("Advertisement Data")) {
                    NavigationLink(destination: AdvertisementDataView(advertisementData: viewModel.advertisementData)) {
                        Text("View Advertisement Data")
                    }
                }
                
                Section(header: Text("Services")) {
                    ForEach(viewModel.services, id: \.uuid) { service in
                        NavigationLink(destination: ServiceDetailView(service: service)) {
                            Text(service.uuid.uuidString)
                        }
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    HStack {
                        Text("Device Details")
                            .font(.headline)
                            .foregroundColor(.white)
                    }
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        bluetoothManager.disconnect(viewModel.peripheral)
                        isPresented = false
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
        .onAppear {
            viewModel.discoverServices()
        }
        .onDisappear {
            bluetoothManager.connectedPeripheral = nil
        }
    }
}

struct AdvertisementDataView: View {
    let advertisementData: [String: Any]
    
    var body: some View {
        List {
            ForEach(Array(advertisementData.keys), id: \.self) { key in
                VStack(alignment: .leading) {
                    Text(key)
                        .font(.headline)
                    Text("\(String(describing: advertisementData[key]!))")
                        .font(.subheadline)
                }
            }
        }
        .navigationTitle("Advertisement Data")
    }
}
