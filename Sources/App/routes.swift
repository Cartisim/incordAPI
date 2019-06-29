import Vapor
import WebSocket

/// Register your application's routes here.
public func routes(_ router: Router) throws {
    // Basic "It works" example
    router.get { req in
        return "inCordAPI"
    }
    
    let channelController = ChannelController()
    try router.register(collection: channelController)
    
    let createAccountController = CreateAccountController()
    try router.register(collection: createAccountController)
    
    let messageController = MessageController()
    try router.register(collection: messageController)
    
    let subChannelController = SubChannelController()
    try router.register(collection: subChannelController)
}

public func socketRouter(_ socketServer: NIOWebSocketServer) throws {
    // Add WebSocket upgrade support to GET /echo
    socketServer.get("api/channel") { ws, req in
        // Add a new on text callback
        ws.onText { ws, text in
            // Simply echo any received text
            ws.send("Connected")
            
        }
    }
}
