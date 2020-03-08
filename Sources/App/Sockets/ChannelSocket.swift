import FluentPostgreSQL
import Vapor
import Authentication




public func socketRouter(_ socketServer: NIOWebSocketServer) throws {
    
    socketServer.get("api") { ws, req in
        print("Connected to Web Socket")
        
        ws.onText { (ws, text) in
            ws.send("Connected to Websocket \(text)")
        }
    }
    
    socketServer.get("api/channel") { ws, req in
        print("Channel Connected")
        
        ws.onBinary{ (ws, data) in
            ws.send(data)
            do {
                let recevied = try JSONDecoder().decode(Channel.self, from: data)
                let channel = Channel(imageString: recevied.imageString!, channel: recevied.channel, createAccountID: recevied.createAccountID )
                let _ = channel.save(on: req)
            } catch let error {
                print("error \(error)")
            }
        }
    }
    
    socketServer.get("api/sub_channel") { ws, req in
        print("SubChannel Connected")
        
        ws.onBinary{ (ws, data) in
            ws.send(data)
            do {
                let received = try JSONDecoder().decode(SubChannel.self, from: data)
                print(received)
                let subChannel = SubChannel(title: received.title, channelID: received.channelID, createAccountID: received.createAccountID)
                let _ = subChannel.save(on: req)
            } catch let error {
                print("Error: \(error)")
            }
        }
    }
    
    socketServer.get("api/messages") { (ws, req) in
        print("Message Connected")
        
        ws.onBinary { (ws, data) in
            ws.send(data)
            do {
                let received = try JSONDecoder().decode(Message.self, from: data)
                print(data.convertToHTTPBody())
                let message = Message(avatar: received.avatar, username: received.username, date: received.date, message: received.message, subChannelID: received.subChannelID, createAccountID: received.createAccountID)
                let _ = message.save(on: req)
            } catch let error {
                print("Error: \(error)")
            }
        }
    }
    
    
    
}
