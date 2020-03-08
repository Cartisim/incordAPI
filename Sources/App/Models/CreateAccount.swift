import Vapor
import FluentPostgreSQL
import Authentication

final class CreateAccount: Content {
    
    var id: UUID?
    var username: String
    var email: String
    var password: String
    var avatar: String
    
    init(username: String, email: String, password: String, avatar: String) {
        self.username = username
        self.email = email
        self.password = password
        self.avatar = avatar
    }
    
    //Returned public account
    final class Public: Content {
        var id: UUID?
        var username: String
        var email: String
        var avatar: String
        
        init(id: UUID?, username: String, email: String, avatar: String) {
            self.id = id
            self.username = username
            self.email = email
            self.avatar = avatar
        }
    }
}

extension CreateAccount: PostgreSQLUUIDModel {}
extension CreateAccount: Migration {
    static func prepare(on connection: PostgreSQLConnection) -> Future<Void> {
        return Database.create(self, on: connection, closure: { (builder) in
            try addProperties(to: builder)
            builder.unique(on: \.username)
        })
    }
}
extension CreateAccount: Parameter {}


//Converts To Public Account
extension CreateAccount {
    func convertToPublic() -> CreateAccount.Public {
        return CreateAccount.Public(id: id, username: username, email: email, avatar: avatar)
    }
}

//An Extension for future only when it is public
extension Future where T: CreateAccount {
    func convertToPublic() -> Future<CreateAccount.Public> {
        return self.map(to: CreateAccount.Public.self, {$0.convertToPublic()})
    }
}

extension CreateAccount: BasicAuthenticatable {
    static let usernameKey: UsernameKey = \CreateAccount.email
    static let passwordKey: PasswordKey = \CreateAccount.password
}

//Allow CreateAccount to use AuthToken
extension CreateAccount: TokenAuthenticatable {
    typealias TokenType = AuthToken
}




struct AdminAccount: Migration {
    
    typealias Database = PostgreSQLDatabase
    
    static func prepare(on conn: PostgreSQLConnection) -> EventLoopFuture<Void> {
        //        let password = String(arc4random_uniform(1_000_000_000))
                       
        guard let hashedPassword = try? BCrypt.hash("password") else {
            fatalError("Could not create Admin Account")
        }
          print("Password \(hashedPassword)")
        let createAccount = CreateAccount(username: "admin", email: "admin", password: hashedPassword, avatar: "avatar1")
        return createAccount.save(on: conn).transform(to: ())
    }
    
    static func revert(on conn: PostgreSQLConnection) -> EventLoopFuture<Void> {
        return .done(on: conn)
    }
}

