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
        case -30...0:
            return "cellularbars.4"
        case -60...(-31):
            return "cellularbars.3"
        case -90...(-61):
            return "cellularbars.2"
        case Int.min...(-91):
            return "cellularbars.1"
        default:
            return "cellularbars.slash"
        }
    }
}
