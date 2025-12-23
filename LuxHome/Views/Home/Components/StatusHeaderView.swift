//
//  StatusHeaderView.swift
//  LuxHome
//
//  Created by RJ Kigner on 12/21/25.
//

import SwiftUI

struct StatusHeaderView: View {
    var body: some View {
        HStack{
        EngravedFont(text: "Maintnence", font: .system(size: 40, weight: .bold))
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal)
        
        Spacer()

        Button {
           //TODO: Ellipse button for moer
        } label: {
            Image(systemName: "ellipsis")
        }
        .buttonStyle(IconButtonStyle(type: .ellipsis))
        .padding(.trailing, 16)
    }
        .background(Color(.orange))

    }
    
}

#Preview {
    StatusHeaderView()
}
