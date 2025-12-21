//
//  StatusTag.swift
//  LuxHome
//
//  Created by RJ Kigner on 12/18/25.
//

import SwiftUI

struct StatusTag: View {
    let status: String

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: statusIcon)
                .font(.caption)
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(.white)

            Text(status)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundStyle(.white)
        }
        .frame(width: 90, height: 28)
        .background {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(statusColor.opacity(0.8))
                .glassEffect(.regular)
        }
    }

    var statusColor: Color {
        switch status {
        case "To Do":
            return .gray
        case "Active":
            return .blue
        case "Overdue":
            return .red
        case "Waiting":
            return .yellow
        default:
            return .gray
        }
    }

    var statusIcon: String {
        switch status {
        case "To Do":
            return "circle"
        case "Active":
            return "play.circle.fill"
        case "Overdue":
            return "exclamationmark.triangle.fill"
        case "Waiting":
            return "clock.fill"
        default:
            return "circle"
        }
    }
}

#Preview {
    VStack(spacing: 16) {
        StatusTag(status: "To Do")
        StatusTag(status: "Active")
        StatusTag(status: "Overdue")
        StatusTag(status: "Waiting")
    }
    .padding()
}
