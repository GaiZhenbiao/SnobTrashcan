//
//  ContentView.swift
//  SnobTrashcan
//
//  Created by Tree Diagram on 2022/12/17.
//

import SwiftUI
import Network
import AlertToast
import OpenAISwift

struct ContentView: View {
    
    let openAI = OpenAISwift(authToken: "")
    
    @State var isUnlocked = false
    
    @State private var message = ""
    let conversationStartingPoint = """
The following is a conversation with a wise and loving trashcan who has an understanding of how complex systems work. The wise trashcan has consumed the majority of the public knowledge of humanity and as a result has immense perspective and wisdom. This trashcan is dedicated to helping the researcher. The trashcan wants to help the researcher be successful. The researcher can ask the trashcan to open its lid to throw trash, and the trashcan must reply with "Opening Lid". Similarly, the researcher can ask the trashcan to close its lid, and the trashcan must reply with "Closing Lid".

The researcher is a human male named Gai Zhenbiao.
"""
    @State var messageHistory = ""
    let gptPrefix = "Trashcan: "
    @State var convMessages: [ConversationMessage] = []
    
    @State var lidAngle: Int = 50
    @State var showingLidControl = false
    
    @State var checkConnectivity = false
    @State var isConnected = false
    
    @State var showingToast = false
    @State var toastMessage = ""
    @State var toastAlertType: AlertToast.AlertType = .complete(.green)
    
    
    @State var showingAlert = false
    @AppStorage(KeyValue.host.rawValue) var alertHostIP = "192.168.31.62"
    @AppStorage(KeyValue.port.rawValue) var alertPort = "2390"
    @State var oldAlertHostIP = ""
    @State var oldAlertPort = ""
    
    @State var connection: NWConnection?
    
    var body: some View {
        NavigationStack {
            ZStack {
                VStack {
                    if convMessages.isEmpty {
                        ScrollView {
                            VStack(spacing: 20) {
                                Spacer()
                                VStack {
                                    HStack{
                                        Image(systemName: "sun.max")
                                        Text("Examples")
                                    }
                                    .font(.title2)
                                    VStack(spacing: 5) {
                                        Text("\"Explain trash in simple terms\"")
                                            .frame(maxWidth: .infinity)
                                        Text("\"Got any creative ideas for throwing trash?\"")
                                            .frame(maxWidth: .infinity)
                                        Text("\"How do I code trash in JavaScript?\"")
                                            .frame(maxWidth: .infinity)
                                    }
                                }
                                VStack {
                                    HStack{
                                        Image(systemName: "smoke")
                                        Text("Capabilities")
                                    }
                                    .font(.title2)
                                    VStack(spacing: 5) {
                                        Text("Forget what user throwed earlier in the day")
                                            .frame(maxWidth: .infinity)
                                        Text("Allow user to provide follow-up corrections")
                                            .frame(maxWidth: .infinity)
                                        Text("Decline users that's not rich")
                                            .frame(maxWidth: .infinity)
                                    }
                                }
                                VStack {
                                    HStack{
                                        Image(systemName: "exclamationmark.triangle")
                                        Text("Limitations")
                                    }
                                    .font(.title2)
                                    VStack(spacing: 5) {
                                        Text("May ocassionally generate correct infomation")
                                            .frame(maxWidth: .infinity)
                                        Text("May occasionally produce useful instructions")
                                            .frame(maxWidth: .infinity)
                                        Text("No knowledge of world after Jesus's birth")
                                            .frame(maxWidth: .infinity)
                                    }
                                }
                            }
                            .textSelection(.enabled)
                        }
                    } else{
                        List {
                            ForEach(convMessages){OneMessage in
                                conversationCellView(conversationMessage: OneMessage)
                            }
                            Section(header: Text("Actions")){
                                Button {
                                    convMessages = []
                                    messageHistory = conversationStartingPoint
                                } label: {
                                    Label("Delete Chat", systemImage: "trash.fill")
                                        .foregroundColor(.red)
                                }
                                .padding(.bottom, 100)
                            }
                        }
                        .listStyle(.inset)
                    }
                }
                .frame(maxHeight: .infinity)
                
                VStack {
                    Spacer()
                    HStack {
                        TextField("Any words to the trashcan...", text: $message)
                            .textFieldStyle(.roundedBorder)
                        Button {
                            NSLog("Send pressed")
                            convMessages.append(ConversationMessage(type: .human, message: message))
                            gptSend(text: message)
                            message = ""
                        } label: {
                            Image(systemName: "paperplane.fill")
                        }
                    }
                    .padding()
                    .background(.thinMaterial)
                }
            }
            .toolbar {
                Button {
                    oldAlertHostIP = alertHostIP
                    oldAlertPort = alertPort
                    showingAlert.toggle()
                } label: {
                    Label("Modify Connection", systemImage: "network")
                }
                Button {
                    checkConnectivity.toggle()
                    connect()
                    checkConnectivity.toggle()
                } label: {
                    if checkConnectivity {
                        ProgressView()
                    } else {
                        Image(systemName: "bolt.horizontal.circle")
                    }
                }
                Button {
                    showingLidControl.toggle()
                } label: {
                    Image(systemName: "gearshape.arrow.triangle.2.circlepath")
                }
            }
            .navigationTitle("Trash GPT")
        }
        .toast(isPresenting: $showingToast) {
            AlertToast(type: toastAlertType, title: toastMessage)
        }
        .onAppear(perform: connect)
        .alert("Modify Connection", isPresented: $showingAlert) {
            TextField("Host IP Address", text: $alertHostIP)
            TextField("Host Port", text: $alertPort)
            Button("Cancel", role: .cancel) {
                alertHostIP = oldAlertHostIP
                alertPort = oldAlertPort
            }
            Button("Confirm", role: .destructive) {
                connect()
            }
        }
        .sheet(isPresented: $showingLidControl){
            athorizedOpenView(lidAngle: Binding(get: {
                self.lidAngle
            }, set: { (newVal) in
                if self.lidAngle != newVal{
                    self.lidAngle = newVal
                    self.sendLidAngle()
                }
            }))
        }
    }
    
    func receive() {
        connection!.receiveMessage { (data, context, isComplete, error) in
            guard let myData = data else { return }
            let received = String(decoding: myData, as: UTF8.self)
            NSLog("Received message: " + received)
            switch received{
            case "passby":
                NSLog("Someone passed by")
                showingLidControl = true
            case "acknowledged":
                ()
            default:
                convMessages.append(ConversationMessage(type: .robot, message: received))
            }
            receive()
        }
    }
    
    
    func send(_ payload: Data) {
            connection!.send(content: payload, completion: .contentProcessed({ sendError in
                if let error = sendError {
                    NSLog("Unable to process and send the data: \(error)")
                } else {
                    NSLog("Data has been sent")
                }
            }))
        }
    
    func sendLidAngle() {
        let LidAngleMessage = "Lid: " + String(lidAngle)
        send(LidAngleMessage.data(using: .utf8)!)
    }
    
    func gptSend(text: String) {
        send(text.data(using: .utf8)!)
        NSLog("Send to GPT: \(messageHistory + text)")
        if messageHistory.isEmpty {
            messageHistory = conversationStartingPoint
        }
        if !text.isEmpty{
            openAI.sendCompletion(with: messageHistory + "\n\nResearcher: \(text)", maxTokens: 100) { result in // Result<OpenAI, OpenAIError>
                switch result {
                case .success(let success):
                    let gptResponse = (success.choices.first?.text ?? "").trimmingCharacters(in: .newlines)
                    messageHistory += "\n\nResearcher: \(text)\n\n\(gptResponse)"
                    if let index = gptResponse.endIndex(of: gptPrefix) {
                        convMessages.append(ConversationMessage(type: .robot, message: String(gptResponse[index...])))
                    }
                    if gptResponse.contains("Opening Lid"){
                        lidAngle = 100
                        sendLidAngle()
                    } else if gptResponse.contains("Closing Lid") {
                        lidAngle = 0
                        sendLidAngle()
                    }
                case .failure(let failure):
                    convMessages.append(ConversationMessage(type: .robot, message: failure.localizedDescription, error: true))
                }
            }
        }
    }
        
    func connect() {
        connection = NWConnection(host: NWEndpoint.Host(alertHostIP), port: NWEndpoint.Port(alertPort) ?? NWEndpoint.Port("2390")!, using: .udp)
        
        connection!.stateUpdateHandler = { (newState) in
            switch (newState) {
            case .preparing:
                NSLog("Entered state: preparing")
            case .ready:
                NSLog("Entered state: ready")
            case .setup:
                NSLog("Entered state: setup")
            case .cancelled:
                NSLog("Entered state: cancelled")
            case .waiting:
                NSLog("Entered state: waiting")
            case .failed:
                NSLog("Entered state: failed")
            default:
                NSLog("Entered an unknown state")
            }
        }
        
        connection!.viabilityUpdateHandler = { (isViable) in
            if (isViable) {
                NSLog("Connection is viable")
                toastMessage = "Connection is viable"
                isConnected = true
                toastAlertType = .complete(.green)
            } else {
                NSLog("Connection is not viable")
                toastMessage = "Connection is not viable"
                isConnected = false
                toastAlertType = .error(.red)
            }
            showingToast = true
        }
        
        connection!.betterPathUpdateHandler = { (betterPathAvailable) in
            if (betterPathAvailable) {
                NSLog("A better path is availble")
            } else {
                NSLog("No better path is available")
            }
        }
        
        connection!.start(queue: .global())
        send("Initial message".data(using: .utf8)!)
        receive()
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(isUnlocked: true, showingToast: false)
        ContentView(convMessages: [ConversationMessage(type: .human, message: "hello?"), ConversationMessage(type: .robot, message: "I'm fine, thankyou. And you?"), ConversationMessage(type: .human, message: "I'm totally ok. Could I throw some trash? I got some banana peel on my hand."), ConversationMessage(type: .robot, message: "Heck yeah. Opening Lid. Please put your rabbish in."), ConversationMessage(type: .human, message: "hello?"), ConversationMessage(type: .robot, message: "I'm fine, thankyou. And you?"), ConversationMessage(type: .human, message: "I'm totally ok. Could I throw some trash? I got some banana peel on my hand."), ConversationMessage(type: .robot, message: "Heck yeah. Opening Lid. Please put your rabbish in."), ConversationMessage(type: .human, message: "hello?"), ConversationMessage(type: .robot, message: "I'm fine, thankyou. And you?"), ConversationMessage(type: .human, message: "I'm totally ok. Could I throw some trash? I got some banana peel on my hand."), ConversationMessage(type: .robot, message: "Heck yeah. Opening Lid. Please put your rabbish in.")])
    }
}
