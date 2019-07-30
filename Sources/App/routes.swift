import Routing
import Vapor
import Foundation
import Fluent

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


