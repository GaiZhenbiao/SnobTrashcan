//
//  lidControlView.swift
//  SnobTrashcan
//
//  Created by Tree Diagram on 2023/2/11.
//

import SwiftUI

struct lidControlView: View {
    @Binding var lidAngle : Int
    var body: some View {
        VStack {
            Spacer()
            Text("⚙️")
                .font(.system(size: 100))
                .padding(.bottom)
                .rotationEffect(Angle(degrees: Double(lidAngle-50)))
            Text("Manual Lid Control")
                .font(.system(size: 25, weight: .bold, design: .rounded))
            Text("Use the slider below to manually adjust the lid angle.")
                .font(.caption)
                .padding(.bottom)
            Spacer()
            Slider(value: .convert(from: $lidAngle), in: 0...100, step: 1)
            Text("Current angle: \(lidAngle)")
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .padding(.bottom)
            HStack {
                Button {
                    lidAngle = 0
                } label: {
                    Label("Close", systemImage: "pedestrian.gate.closed")
                        .labelStyle(.titleAndIcon)
                        .font(.system(size: 20, design: .rounded))
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                Button {
                    lidAngle = 100
                } label: {
                    Label("Open", systemImage: "pedestrian.gate.open")
                        .labelStyle(.titleAndIcon)
                        .font(.system(size: 20, design: .rounded))
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
            }
            Spacer()
        }
        .padding()
    }
}

struct lidControlView_Previews: PreviewProvider {
    static var previews: some View {
        lidControlView(lidAngle: .constant(50))
    }
}
