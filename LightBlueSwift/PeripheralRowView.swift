//
//  PeripheralRowView.swift
//  LightBlueSwift
//
//  Created by user on 2024/10/17.
//

import SwiftUI
import CoreBluetooth

struct PeripheralRowView: View {
    let peripheral: CBPeripheral
    let rssi: NSNumber
    let connectAction: () -> Void
    
    var body: some View {
        HStack(spacing: 10) {
            // RSSI column
            VStack(alignment: .center) {
                Image(systemName: rssiIcon)
                    .font(.title2)
                Text("\(rssi.intValue) dBm")
                    .font(.caption2)
            }
            .frame(width: 60)
            
            // Name column
            Text(peripheral.name ?? "Unknown Device")
                .font(.subheadline)
                .lineLimit(1)
                .truncationMode(.tail)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            // Connect button column
            Button("Connect") {
                connectAction()
            }
            .buttonStyle(BorderedButtonStyle())
            .frame(width: 100)  // Increased width
        }
    }
    
    var rssiIcon: String {
        let rssiValue = rssi.intValue
        switch rssiValue {
        case -50...0:
            return "cellularbars"
        case -65...(-51):
            return "cellularbars"
        case -80...(-66):
            return "cellularbars"
        case Int.min...(-81):
            return "cellularbars"
        default:
            return "cellularbars.slash"
        }
    }
}
