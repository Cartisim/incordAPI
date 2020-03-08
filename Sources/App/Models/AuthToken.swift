import Vapor
import FluentPostgreSQL
import Authentication

final class AuthToken: Content {
    
    var id: UUID?
    var token: String
    var createAccountID: CreateAccount.ID
    
    init(token: String, createAccountID: CreateAccount.ID) {
        self.token = token
        self.createAccountID = createAccountID
    }
}

extension AuthToken: PostgreSQLUUIDModel{}
extension AuthToken: Parameter{}

//This function  uses foreign key contraint so that you can not use AuthToken Without a valid CreateAccount.id
extension AuthToken: Migration{
    static func preparation(on connection: PostgreSQLConnection) -> Future<Void> {
        return Database.create(self, on: connection, closure: { (builder) in
            try addProperties(to: builder)
            builder.reference(from: \.createAccountID, to: \CreateAccount.id)
        })
    }
}

//Generate your random token
extension AuthToken {
    static func generate(for createAccount: CreateAccount) throws -> AuthToken {
        let random = try CryptoRandom().generateData(count: 64)
        return try AuthToken(token: random.base64EncodedString(), createAccountID: createAccount.requireID())
    }
}

//Set the token value for the header bearer
extension AuthToken: BearerAuthenticatable {
    static let tokenKey: TokenKey = \.token
}

//After setting the value for the header create a prototcol for AuthToken
extension AuthToken: Authentication.Token {
    typealias UserType = CreateAccount
    static let userIDKey: UserIDKey = \.createAccountID
}


