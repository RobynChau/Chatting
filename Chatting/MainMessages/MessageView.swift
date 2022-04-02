//
//  MessageView.swift
//  Chatting
//
//  Created by Robyn Chau on 31/03/2022.
//

import SwiftUI

struct MessageView: View {
    let message: ChatMessage
    var body: some View {
        HStack {
            Group {
                if message.isFromID {
                    Spacer()
                }
            }
            HStack {
                Text(message.text)
                    .foregroundColor(message.isFromID ? .white : .primary)
            }
            .padding()
            .background(message.isFromID ? .blue : .gray.opacity(0.2))
            .clipShape(RoundedRectangle(cornerRadius: 16))

            Group {
                if !message.isFromID {
                    Spacer()
                }
            }
        }
        .padding(.horizontal)
        .padding(.bottom, 8)
    }
}
