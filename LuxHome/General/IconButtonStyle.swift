//
//  IconButtonStyle.swift
//  LuxHome
//
//  Created by RJ Kigner on 12/18/25.
//

import SwiftUI

enum IconType {
    case close
    case clearText
    case back
    case plus
    case check
    case ellipsis
}

struct IconButtonStyle: ButtonStyle {
    let type: IconType
    @Environment(\.colorScheme) var colorScheme

    func makeBody(configuration: Configuration) -> some View {
        Image(systemName: iconName)
            .font(.system(size: iconFontSize, weight: .semibold))
            .foregroundStyle(foregroundColor)
            .frame(width: buttonSize, height: buttonSize)
            .glassEffect(glassStyle, in: .circle)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.bouncy, value: configuration.isPressed)
    }

    private var iconName: String {
        switch type {
        case .close, .clearText:
            return "xmark"
        case .back:
            return "chevron.left"
        case .plus:
            return "plus"
        case .check:
            return "checkmark"
        case .ellipsis:
            return "ellipsis"
        }
    }

    private var buttonSize: CGFloat {
        switch type {
        case .close, .check:
            return 48
        case .clearText, .back:
            return 48
        case .ellipsis:
            return 48
        case .plus:
            return 48
        }
    }

    private var iconFontSize: CGFloat {
        switch type {
        case .close, .check:
            return 16
        case .clearText, .back, .ellipsis:
            return 19
        case .plus:
            return 19
        }
    }

    private var foregroundColor: Color {
        switch type {
        case .close, .clearText, .back, .ellipsis:
            return colorScheme == .dark ? .primary : .black
        case .plus, .check:
            return .white
        }
    }

    private var glassStyle: Glass {
        switch type {
        case .close, .clearText, .back, .ellipsis:
            return .regular.interactive()
        case .plus:
            return .regular.tint(Color.orange).interactive()
        case .check:
            return .regular.tint(Color.orange).interactive()
        }
    }
}

extension ButtonStyle where Self == IconButtonStyle {
    static func icon(_ type: IconType) -> IconButtonStyle {
        IconButtonStyle(type: type)
    }

    static var iconClose: IconButtonStyle {
        IconButtonStyle(type: .close)
    }

    static var iconBack: IconButtonStyle {
        IconButtonStyle(type: .back)
    }

    static var iconPlus: IconButtonStyle {
        IconButtonStyle(type: .plus)
    }

    static var iconCheck: IconButtonStyle {
        IconButtonStyle(type: .check)
    }

    static var iconClearText: IconButtonStyle {
        IconButtonStyle(type: .clearText)
    }

    static var iconEllipsis: IconButtonStyle {
        IconButtonStyle(type: .ellipsis)
    }
}

#Preview {
    VStack(spacing: 20) {
        Button("Close") {}
            .buttonStyle(.iconClose)

        Button("Back") {}
            .buttonStyle(.iconBack)

        Button("Plus") {}
            .buttonStyle(.iconPlus)

        Button("Check") {}
            .buttonStyle(.iconCheck)

        Button("Clear") {}
            .buttonStyle(.icon(.clearText))

        Button("Ellipsis") {}
            .buttonStyle(.iconEllipsis)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color(.systemGray6))
}
