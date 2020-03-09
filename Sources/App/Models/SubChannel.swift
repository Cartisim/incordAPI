import Vapor
import FluentPostgreSQL

final class SubChannel: Codable {
    
    var id: Int?
    var title: String
    var createAccountID: CreateAccount.ID?
    var channelID: Channel.ID
    
    init(title: String, channelID: Channel.ID, createAccountID: CreateAccount.ID?) {
        self.title = title
        self.channelID = channelID
        self.createAccountID = createAccountID
    }
}

extension SubChannel: PostgreSQLModel {}
extension SubChannel: Migration {
    static func preparation(on connection: PostgreSQLConnection) -> Future<Void> {
           return Database.create(self, on: connection, closure: { (builder) in
               try addProperties(to: builder)
            builder.reference(from: \.channelID, to: \Channel.id, onDelete: .cascade)
           })
       }
}
extension SubChannel: Parameter {}
extension SubChannel {
    var channel: Parent<SubChannel, Channel> {
        return parent(\.channelID)
    }
}
extension SubChannel {
    var message: Children<SubChannel, Message> {
        return children(\.subChannelID)
    }
}


