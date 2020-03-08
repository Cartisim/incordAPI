import Vapor
import Fluent
import Authentication

struct MessageController: RouteCollection {
    func boot(router: Router) throws {
        print("booted")
        
        //This sets ever messageRoute as api/message
        let messageRoute = router.grouped("api", "message")
        let tokenAuthMiddleware = CreateAccount.tokenAuthMiddleware()
        let guardAuthMiddleware = CreateAccount.guardAuthMiddleware()
        let tokenAuthGroup = messageRoute.grouped(tokenAuthMiddleware, guardAuthMiddleware)
        //When we get to /api/message we will retrieve all the messages
        tokenAuthGroup.get(use: getAllMessagesHandler)
        tokenAuthGroup.get(Message.parameter, use: getMessage)
        //When we delete to /api/message a message will be deleted
        tokenAuthGroup.delete(Message.parameter, use: deleteMessageHandler)
        
    }
    
    func getAllMessagesHandler(_ request: Request) throws -> Future<[Message]> {
        print(request)
        return Message.query(on: request).all()
    }
    
    func getMessage(_ request: Request) throws -> Future<Message> {
        return try request.parameters.next(Message.self)
    }
    
    func deleteMessageHandler(_ request: Request) throws -> Future<HTTPStatus> {
        return try request.parameters.next(Message.self).delete(on: request).transform(to: HTTPStatus.noContent)
    }
}



