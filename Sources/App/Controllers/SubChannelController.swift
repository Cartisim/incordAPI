import Vapor
import Fluent
import Authentication

struct SubChannelController: RouteCollection {
    func boot(router: Router) throws {
        print("booted")
        
        //This sets every subChannelRoute as api/sub_channel
        let subChannelRoutes = router.grouped("api", "sub_channel")
        let tokenAuthMiddleware = CreateAccount.tokenAuthMiddleware()
        let guardAuthMiddleware = CreateAccount.guardAuthMiddleware()
        let tokenAuthGroup = subChannelRoutes.grouped(tokenAuthMiddleware, guardAuthMiddleware)
        //When we get to /api/sub_channel id will retrieve all the sub_channels
        tokenAuthGroup.get(use: getAllSubChannelsHandler)
        //When we put to /api/sub_channel a sub_channels content will be updated
        tokenAuthGroup.delete(SubChannel.parameter, use: deleteSubHandler)
        //Get Parent element from Child
        tokenAuthGroup.get(SubChannel.parameter, "channel", use: getChannelHandler)
        //Get Messages from SubChannel
        tokenAuthGroup.get(SubChannel.parameter,  "messages", use: getMessagesHandler)
        //        subChannelRoutes.put(CreateSubChannelData.self, at: SubChannel.parameter, use: updateHandler)
    }
    
    func getAllSubChannelsHandler(_ request: Request) throws -> Future <[SubChannel]> {
        return SubChannel.query(on: request).all()
    }
    
    func deleteSubHandler(_ request: Request) throws -> Future<HTTPStatus> {
        return try request.parameters.next(SubChannel.self).delete(on: request).transform(to: HTTPStatus.noContent)
    }
    
    func getChannelHandler(_ request: Request) throws -> Future<Channel> {
        return try request.parameters.next(SubChannel.self).flatMap(to: Channel.self, { (subChannel) -> EventLoopFuture<Channel> in
            return subChannel.channel.get(on: request)
        })
    }
    
    func getMessagesHandler(_ request: Request) throws -> Future<[Message]> {
        return try request.parameters.next(SubChannel.self).flatMap(to: [Message].self, { (messages) -> EventLoopFuture<[Message]> in
            return try messages.message.query(on: request).all()
        })
    }
}
