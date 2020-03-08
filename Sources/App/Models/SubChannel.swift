import Vapor
import FluentPostgreSQL

final class SubChannel: Content {
    
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
extension SubChannel: Migration {}
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


