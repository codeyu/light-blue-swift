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
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                FilterView(searchText: $searchText, hideUnknownDevices: $hideUnknownDevices)
                    .padding(.horizontal)
                    .padding(.vertical, 10)
                    .background(Color(.systemGray6))
                
                List(filteredPeripherals, id: \.identifier) { peripheral in
                    NavigationLink(destination: PeripheralDetailView(peripheral: peripheral)) {
                        Text(peripheral.name ?? "Unknown Device")
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
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .accentColor(.white)
    }
    
    var filteredPeripherals: [CBPeripheral] {
        bluetoothManager.discoveredPeripherals.filter { peripheral in
            let nameMatch = searchText.isEmpty || peripheral.name?.lowercased().contains(searchText.lowercased()) ?? false
            let unknownFilter = !hideUnknownDevices || (peripheral.name != nil && peripheral.name != "Unknown Device")
            return nameMatch && unknownFilter
        }
    }
}
