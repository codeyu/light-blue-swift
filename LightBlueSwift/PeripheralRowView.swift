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
            VStack {
                BluetoothSignalIcon(rssi: Int(truncating: rssi))
                    .frame(width: 30, height: 20)  // 固定大小
                Text("\(Int(truncating: rssi)) dBm")
                    .font(.caption)
            }
            .frame(width: 80)  // 增加宽度
            
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
            .buttonStyle(BorderedProminentButtonStyle())  // 使用更突出的样式
            .tint(.blue)  // 设置按钮的色调
            .frame(width: 100)  // 保持宽度
        }
    }
}

struct BluetoothSignalIcon: View {
    let rssi: Int
    
    private var signalStrength: Int {
        switch rssi {
        case -50...(-30): return 4  // Very strong
        case -70...(-51): return 3  // Good
        case -90...(-71): return 2  // Weak
        case ...(-91):    return 1  // Very weak
        default:          return 0  // No signal or invalid
        }
    }
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 1) {
            ForEach(0..<4) { index in
                Rectangle()
                    .fill(index < self.signalStrength ? Color.blue : Color.gray.opacity(0.3))
                    .frame(width: 3, height: 4 + CGFloat(index) * 4)
            }
        }
        .frame(height: 20)  // Set a fixed height for the icon
    }
}
