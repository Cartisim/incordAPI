import Vapor
import FluentPostgreSQL

final class Message: Content {
    
    var id: Int?
    var avatar: String
    var username: String
    var date: String
    var message: String
    var subChannelID: SubChannel.ID
    var createAccountID: CreateAccount.ID? 
    
    
    init(avatar: String, username: String, date: String, message: String, subChannelID: SubChannel.ID, createAccountID: CreateAccount.ID?) {
        self.avatar = avatar
        self.username = username
        self.date = date
        self.message = message
        self.subChannelID = subChannelID
        self.createAccountID = createAccountID
    }
}

extension Message: PostgreSQLModel {}
extension Message: Migration {
    static func preparation(on connection: PostgreSQLConnection) -> Future<Void> {
           return Database.create(self, on: connection, closure: { (builder) in
               try addProperties(to: builder)
            builder.reference(from: \.subChannelID, to: \SubChannel.id, onDelete: .cascade)
           })
       }
}
extension Message: Parameter {}
extension Message {
    var subChannel: Parent<Message, SubChannel> {
        return parent(\.subChannelID)
    }
}


