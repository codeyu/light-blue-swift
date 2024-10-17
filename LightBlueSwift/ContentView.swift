//
//  ContentView.swift
//  LightBlueSwift
//
//  Created by user on 2024/10/17.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var bluetoothManager = BluetoothManager()
    
    var body: some View {
        NavigationView {
            List(bluetoothManager.discoveredPeripherals, id: \.identifier) { peripheral in
                NavigationLink(destination: PeripheralDetailView(peripheral: peripheral)) {
                    Text(peripheral.name ?? "Unknown Device")
                }
            }
            .navigationTitle("LightBlueSwift")
            .navigationBarItems(trailing: Button(action: {
                bluetoothManager.startScanning()
            }) {
                Image(systemName: "arrow.clockwise")
            })
        }
    }
}
