//
//  athorizedOpenView.swift
//  SnobTrashcan
//
//  Created by Tree Diagram on 2023/2/11.
//

import SwiftUI
import LocalAuthentication

struct athorizedOpenView: View {
    
    @Binding var lidAngle : Int
    @State var isUnlocked: Bool = false
    
    var body: some View {
        VStack {
            if isUnlocked {
                lidControlView(lidAngle: $lidAngle)
            } else {
                Spacer()
                Text("🔒")
                    .font(.system(size: 100))
                    .padding(.bottom)
                Text("Authentication Required")
                    .font(.system(size: 25, weight: .bold, design: .rounded))
                Text("You need to be authenticated before throwing trash")
                    .font(.caption)
                    .padding(.bottom)
                Spacer()
                Button {
                    authenticate()
                } label: {
                    Label("Authorize", systemImage: "faceid")
                        .labelStyle(.titleAndIcon)
                        .font(.system(size: 20, design: .rounded))
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .onAppear(perform: authenticate)
    }
    
    func authenticate() {
        let context = LAContext()
        var error: NSError?
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error){
            // code here will be run if can use FaceID
            let reason = "Do you have the previlage of using the trashcan?"
            
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) {success, authenticationError in
                if success {
                    // authentivate succesfully
                    isUnlocked = true
                } else {
                    // there was a promblem
                }
            }
        } else {
            // no biometrics
        }
    }
}

struct athorizedOpenView_Previews: PreviewProvider {
    static var previews: some View {
        athorizedOpenView(lidAngle: .constant(50), isUnlocked: false)
        athorizedOpenView(lidAngle: .constant(50), isUnlocked: true)
    }
}
