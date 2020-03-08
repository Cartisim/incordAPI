import Vapor
import FluentPostgreSQL

final class ChannelImage: Codable {
    var id: Int?
    var image: Data
    
    init(image: Data) {
        self.image = image
    }
    
}

extension ChannelImage: PostgreSQLModel {}
extension ChannelImage: Parameter {}
extension ChannelImage: Migration {}
extension ChannelImage: Content {}
