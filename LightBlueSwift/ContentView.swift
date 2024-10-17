//
//  ContentView.swift
//  LightBlueSwift
//
//  Created by user on 2024/10/17.
//

import SwiftUI
import CoreBluetooth

struct ContentView: View {
    @StateObject private var bluetoothManager = BluetoothManager()
    @State private var searchText = ""
    @State private var hideUnknownDevices = false
    @State private var selectedPeripheral: CBPeripheral?
    @State private var isConnecting = false
    @State private var isNavigatingToDetail = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                FilterView(searchText: $searchText, hideUnknownDevices: $hideUnknownDevices)
                    .padding(.horizontal)
                    .padding(.vertical, 10)
                    .background(Color(.systemGray6))
                
                List {
                    ForEach(filteredPeripherals, id: \.peripheral.identifier) { (peripheral, rssi) in
                        PeripheralRowView(peripheral: peripheral, rssi: rssi) {
                            selectedPeripheral = peripheral
                            isConnecting = true
                            bluetoothManager.connect(to: peripheral) { success in
                                DispatchQueue.main.async {
                                    isConnecting = false
                                    if success {
                                        print("Connection successful, navigating to detail view")
                                        isNavigatingToDetail = true
                                    } else {
                                        print("Connection failed")
                                    }
                                }
                            }
                        }
                    }
                }
                .listStyle(PlainListStyle())
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    HStack {
                        Text("LightBlue")
                            .font(.headline)
                            .foregroundColor(.white)
                        Image(systemName: "swift")
                            .foregroundColor(.white)
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        bluetoothManager.startScanning()
                    }) {
                        Image(systemName: "arrow.clockwise")
                            .foregroundColor(.white)
                    }
                }
            }
            .background(
                NavigationLink(destination: Group {
                    if let peripheral = selectedPeripheral {
                        PeripheralDetailView(
                            peripheral: peripheral,
                            bluetoothManager: bluetoothManager,
                            isPresented: $isNavigatingToDetail
                        )
                    }
                }, isActive: $isNavigatingToDetail) {
                    EmptyView()
                }
            )
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .accentColor(.white)
        .alert(isPresented: $isConnecting) {
            Alert(
                title: Text("Connecting"),
                message: Text("Attempting to connect to \(selectedPeripheral?.name ?? "device")..."),
                dismissButton: .cancel {
                    if let peripheral = selectedPeripheral {
                        bluetoothManager.cancelConnection(peripheral)
                    }
                }
            )
        }
    }
    
    var filteredPeripherals: [(peripheral: CBPeripheral, rssi: NSNumber)] {
        bluetoothManager.discoveredPeripherals.filter { peripheral, rssi in
            let nameMatch = searchText.isEmpty || peripheral.name?.lowercased().contains(searchText.lowercased()) ?? false
            let unknownFilter = !hideUnknownDevices || (peripheral.name != nil && peripheral.name != "Unknown Device")
            return nameMatch && unknownFilter
        }
    }
}
