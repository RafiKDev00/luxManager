//
//  RecurringIntervalPicker.swift
//  LuxHome
//
//  Created by RJ Kigner on 12/28/25.
//

import SwiftUI

struct RecurringIntervalPicker: View {
    @Binding var interval: Int
    @Binding var unit: RecurringInterval

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Repeats")
                .font(.caption)
                .foregroundStyle(.secondary)

            HStack(spacing: 0) {
                Text("Every")
                    .foregroundStyle(.primary)

                Picker("Interval", selection: $interval) {
                    ForEach(1...12, id: \.self) { number in
                        Text("\(number)").tag(number)
                    }
                }
                .pickerStyle(.wheel)
                .frame(width: 80, height: 100)
                .clipped()

                Picker("Unit", selection: $unit) {
                    ForEach(RecurringInterval.allCases, id: \.self) { intervalUnit in
                        Text(intervalUnit.rawValue).tag(intervalUnit)
                    }
                }
                .pickerStyle(.wheel)
                .frame(width: 120, height: 100)
                .clipped()
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
    }
}

#Preview {
    @Previewable @State var interval = 2
    @Previewable @State var unit: RecurringInterval = .weeks

    Form {
        RecurringIntervalPicker(
            interval: $interval,
            unit: $unit
        )
    }
}
