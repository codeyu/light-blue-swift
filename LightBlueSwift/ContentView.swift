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
    @State private var showingDetailView = false
    
    var body: some View {
        ZStack {
            NavigationView {
                VStack(spacing: 0) {
                    FilterView(searchText: $searchText, hideUnknownDevices: $hideUnknownDevices)
                        .padding(.horizontal)
                        .padding(.vertical, 10)
                        .background(Color(.systemGray6))
                    
                    List {
                        ForEach(filteredPeripherals, id: \.peripheral.identifier) { (peripheral, rssi) in
                            PeripheralRowView(peripheral: peripheral, rssi: rssi) {
                                connectToPeripheral(peripheral)
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
                            resetAndStartScanning()
                        }) {
                            Image(systemName: "arrow.clockwise")
                                .foregroundColor(.white)
                        }
                    }
                }
            }
            .navigationViewStyle(StackNavigationViewStyle())
            .accentColor(.white)
            
            if showingDetailView, let peripheral = selectedPeripheral {
                PeripheralDetailView(peripheral: peripheral, bluetoothManager: bluetoothManager, dismiss: dismissDetailView)
                    .transition(.move(edge: .bottom))
                    .zIndex(1)
            }
        }
        .alert(isPresented: $isConnecting) {
            Alert(
                title: Text("Connecting"),
                message: Text("Attempting to connect to \(selectedPeripheral?.name ?? "device")..."),
                dismissButton: .cancel {
                    if let peripheral = selectedPeripheral {
                        bluetoothManager.disconnect(peripheral)
                    }
                }
            )
        }
    }
    
    private func connectToPeripheral(_ peripheral: CBPeripheral) {
        resetState()
        selectedPeripheral = peripheral
        isConnecting = true
        bluetoothManager.connect(to: peripheral) { success in
            DispatchQueue.main.async {
                isConnecting = false
                if success {
                    showingDetailView = true
                } else {
                    selectedPeripheral = nil
                }
            }
        }
    }
    
    private func resetAndStartScanning() {
        resetState()
        bluetoothManager.resetState()
        bluetoothManager.startScanning()
    }
    
    private func resetState() {
        selectedPeripheral = nil
        showingDetailView = false
        isConnecting = false
    }
    
    private func dismissDetailView() {
        withAnimation {
            showingDetailView = false
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            resetState()
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
