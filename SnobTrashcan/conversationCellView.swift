//
//  conversationCellView.swift
//  SnobTrashcan
//
//  Created by Tree Diagram on 2023/2/11.
//

import SwiftUI

struct conversationCellView: View {
    
    @State var conversationMessage: ConversationMessage
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        HStack(alignment: .top) {
            switch conversationMessage.type{
            case .human:
                Image(systemName: "person.fill")
            case .robot:
                Image(systemName: "cloud.fill")
            }
            if conversationMessage.error {
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                    Text(conversationMessage.message)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .textSelection(.enabled)
                }
                .foregroundColor(.red)
                
            } else {
                Text(conversationMessage.message)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .textSelection(.enabled)
            }
        }
        .padding(.vertical)
        .listRowBackground(conversationMessage.type == .robot ? robotColor: humanColor)
    }
    
    private var robotColor: Color {
        switch colorScheme {
            case .light:
                return Color.secondary.opacity(0.05)
            case .dark:
                return Color.white.opacity(0.1)
            @unknown default:
                return Color.secondary.opacity(0.05)
        }
    }
    
    private var humanColor: Color {
        switch colorScheme {
            case .light:
                return Color.white
            case .dark:
            return Color.black
            @unknown default:
            return Color.white
        }
    }
}

struct conversationCellView_Previews: PreviewProvider {
    static var previews: some View {
        conversationCellView(conversationMessage: ConversationMessage(type: .human, message: "looooong human text looooong human text looooong human text looooong human text looooong human text"))
        conversationCellView(conversationMessage: ConversationMessage(type: .robot, message: "looooong robot text looooong robot text looooong robot text looooong robot text looooong robot text"))
        conversationCellView(conversationMessage: ConversationMessage(type: .robot, message: "looooong error text looooong error text looooong error text looooong error text looooong error text", error: true))
    }
}
