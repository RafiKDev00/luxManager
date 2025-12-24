//
//  HistorySearchBar.swift
//  LuxHome
//
//  Created by RJ Kigner on 12/23/25.
//

import SwiftUI

struct HistorySearchBar: View {
    @Binding var searchText: String
    @FocusState.Binding var isFocused: Bool
    @Namespace private var glassNamespace
    

    var body: some View {
        HStack(spacing: 16) {
            HStack(spacing: 10) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.secondary)
                    .font(.system(size: 15, weight: .semibold))

                TextField("Search by name or date", text: $searchText)
                    .textFieldStyle(.plain)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                    .focused($isFocused)
                    .tint(.orange)

                if !searchText.isEmpty {
                    Button {
                        searchText = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.orange)
                            .font(.system(size: 16, weight: .semibold))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 12)
            .frame(height: 48)
            .frame(maxWidth: .infinity)
            .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 24))
            .glassEffectID("historySearch", in: glassNamespace)
            .animation(.smooth(duration: 0.2), value: isFocused)

            Button {
                searchText = ""
                isFocused = false
                dismissKeyboard()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 19, weight: .semibold))
            }
            .buttonStyle(.iconClose)
            .frame(width: 48, height: 48)
            .contentShape(Rectangle())
            .glassEffectID("historyClose", in: glassNamespace)
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 8)
    }

    private func dismissKeyboard() {
        isFocused = false
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

#Preview("Empty") {
    @Previewable @State var searchText = ""
    @Previewable @FocusState var isFocused: Bool
    HistorySearchBar(searchText: $searchText, isFocused: $isFocused)
}

#Preview("With Text") {
    @Previewable @State var searchText = "Kitchen"
    @Previewable @FocusState var isFocused: Bool
    HistorySearchBar(searchText: $searchText, isFocused: $isFocused)
}
