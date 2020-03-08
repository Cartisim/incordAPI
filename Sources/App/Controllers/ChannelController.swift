import Vapor
import Fluent

struct ChannelController: RouteCollection {
    func boot(router: Router) throws {
        
        let channelRoute = router.grouped("api", "channel")
        let tokenAuthMiddleware = CreateAccount.tokenAuthMiddleware()
        let guardAuthMiddleware = CreateAccount.guardAuthMiddleware()
        let tokenAuthGroup = channelRoute.grouped(tokenAuthMiddleware, guardAuthMiddleware)
       tokenAuthGroup.get(use: getAllHandler)
       tokenAuthGroup.get(Channel.parameter, use: getHandler)
       tokenAuthGroup.delete(Channel.parameter, use: deleteHandler)
         
       tokenAuthGroup.get(Channel.parameter, "sub_channel", use: getSubChannelHandler)
       tokenAuthGroup.post("image", Channel.parameter, "channelImage", use: addImageChannel)
       tokenAuthGroup.get("image", Channel.parameter, "channelImage", use: getChannelImage)
       tokenAuthGroup.delete("image", Channel.parameter, "channelImage", use: deleteChannelImageHandler)
    }
}

func getAllHandler(_ request: Request) throws -> Future<[Channel]> {
    return Channel.query(on: request).all()
}

func getHandler(_ request: Request) throws -> Future<Channel> {
    return try request.parameters.next(Channel.self)
}

func addImageChannel(_ request: Request) throws -> Future<Response> {
    return try flatMap(to: Response.self, request.parameters.next(Channel.self), request.content.decode(ChannelImage.self), { (channel, imageData) in
        let workPath = try request.make(DirectoryConfig.self).workDir
        let stringName = try "\(channel.requireID())-\(UUID().uuidString).mp4"
        let path = workPath + Constants.shared.imageFolder + stringName
        FileManager().createFile(atPath: path, contents: imageData.image, attributes: nil)
        channel.imageString = stringName
        return channel.save(on: request).encode(status: HTTPStatus.accepted, for: request)
    })
}

func getChannelImage(_ request: Request) throws -> Future<Response> {
    return try request.parameters.next(Channel.self).flatMap(to: Response.self, { (channel) in
        guard let fileName = channel.imageString else {throw Abort(.notFound)}
        let path =  try request.make(DirectoryConfig.self).workDir + Constants.shared.imageFolder + fileName
        return try request.streamFile(at: path)
    })
}

func deleteHandler(_ request: Request) throws -> Future<HTTPStatus> {
    return try request.parameters.next(Channel.self).delete(on: request).transform(to: HTTPStatus.noContent)
}

func deleteChannelImageHandler(_ request: Request) throws -> Future<HTTPStatus> {
    return try request.parameters.next(Channel.self).flatMap(to: HTTPStatus.self) { channel in
        guard let file = channel.imageString else {throw Abort(.notFound)}
        let path = try request.make(DirectoryConfig.self).workDir + Constants.shared.imageFolder + file
        try FileManager().removeItem(atPath: path)
        return channel.delete(on: request).transform(to: HTTPStatus.noContent)
    }
}

func getChannelsImage(_ request: Request) throws -> Future<Response> {
    return try request.parameters.next(Channel.self).flatMap(to: Response.self) { channel in
        guard let filename = channel.imageString else { throw Abort(.notFound) }
        let path = try request.make(DirectoryConfig.self).workDir + Constants.shared.imageFolder + filename
        return try request.streamFile(at: path)
    }
}

func getSubChannelHandler(_ request: Request) throws -> Future<[SubChannel]>{
    return try request.parameters.next(Channel.self).flatMap(to: [SubChannel].self, { (channel) -> EventLoopFuture<[SubChannel]> in
        return try channel.subChannel.query(on: request).all()
    })
    
    //TODO:-Delete children with parents
//    func deleteChannelSubChannels(_ request: Request) throws -> Future<[SubChannel]> {
//        return try request.parameters.next(Channel.self).flatMap(to: [SubChannel].self, { (channel) -> EventLoopFuture<[SubChannel]> in
//            return channel.subChannel.parent.delete(on: request)
//        })
//    }
}



