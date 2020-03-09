import Vapor
import FluentPostgreSQL

final class Channel: Codable {
    
    var id: Int?
    var imageString: String?
    var channel: String
    var createAccountID: CreateAccount.ID?
    
    init(imageString: String, channel: String, createAccountID: CreateAccount.ID?) {
        self.imageString = imageString
        self.channel = channel
        self.createAccountID = createAccountID
    }
}

extension Channel: PostgreSQLModel {}
//This function  uses foreign key contraint so that you can not use AuthToken Without a valid CreateAccount.id
extension Channel: Migration {
    static func preparation(on connection: PostgreSQLConnection) -> Future<Void> {
        return Database.create(self, on: connection, closure: { (builder) in
            try addProperties(to: builder)
            builder.reference(from: \.createAccountID, to: \CreateAccount.id)  
        })
    }
}
extension Channel: Content {}
extension Channel: Parameter {}
extension Channel {
    var subChannel: Children<Channel, SubChannel> {
        return children(\.channelID)
        
    }
}

