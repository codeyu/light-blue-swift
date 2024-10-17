//
//  FilterView.swift
//  LightBlueSwift
//
//  Created by user on 2024/10/17.
//

import SwiftUI

struct FilterView: View {
    @Binding var searchText: String
    @Binding var hideUnknownDevices: Bool
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                TextField("Search devices", text: $searchText)
                    .textFieldStyle(PlainTextFieldStyle())
                if !searchText.isEmpty {
                    Button(action: {
                        searchText = ""
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding(8)
            .background(Color(.systemBackground))
            .cornerRadius(10)
            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
            
            Toggle(isOn: $hideUnknownDevices) {
                Text("Hide Unknown Devices")
                    .font(.subheadline)
            }
            .padding(.horizontal, 4)
        }
    }
}
