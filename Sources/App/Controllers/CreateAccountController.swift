import Vapor
import Fluent
import Crypto

struct CreateAccountController: RouteCollection {
    func boot(router: Router) throws {
        print("booted")
        
        let createAccountRoute = router.grouped("api", "create_account")

        createAccountRoute.get(use: getAllAccountsHandler)
        createAccountRoute.get(CreateAccount.parameter, use: getOneAccountHandler)

        createAccountRoute.delete(CreateAccount.parameter, use: deleteHandler)
        let tokenAuthMiddleware =  CreateAccount.tokenAuthMiddleware()
        let guardAuthMiddleware = CreateAccount.guardAuthMiddleware()
        let tokenAuthRoute = createAccountRoute.grouped(tokenAuthMiddleware, guardAuthMiddleware)
        tokenAuthRoute.post(CreateAccount.self, use: createHandler)
        tokenAuthRoute.put(CreateAccount.self, at: CreateAccount.parameter, use: updateHandler)

        let basicAuthMiddleware = CreateAccount.basicAuthMiddleware(using: BCryptDigest())
        let basicAuthRoutes = createAccountRoute.grouped(basicAuthMiddleware)
        basicAuthRoutes.post("login", use: loginHandler)
    }
    
    func createHandler(_ request: Request, account: CreateAccount) throws -> Future<CreateAccount.Public> {
        account.password = try BCrypt.hash(account.password)
        return account.save(on: request).convertToPublic()
    }
    
    func getAllAccountsHandler(_ request: Request) throws -> Future<[CreateAccount.Public]> {
        return CreateAccount.query(on: request).decode(data: CreateAccount.Public.self).all()
    }
    
    func getOneAccountHandler(_ request: Request) throws -> Future<CreateAccount.Public> {
        return try request.parameters.next(CreateAccount.self).convertToPublic()
    }
    
    func updateHandler(_ request: Request, updateAccount: CreateAccount) throws -> Future<CreateAccount.Public> {
        return try request.parameters.next(CreateAccount.self).flatMap({ (account) -> EventLoopFuture<CreateAccount.Public> in
            account.avatar = updateAccount.avatar
            account.email = updateAccount.email
            account.password = try BCrypt.hash(updateAccount.password)
            account.username = updateAccount.username
            return account.save(on: request).convertToPublic()
        })
    }
    
    func deleteHandler(_ request: Request) throws -> Future<HTTPStatus> {
        return try request.parameters.next(CreateAccount.self).delete(on: request).transform(to: HTTPStatus.noContent)
    }
}

//Login to generate token
func loginHandler(_ request: Request) throws -> Future<AuthToken> {
    let createAccount = try request.requireAuthenticated(CreateAccount.self)
    let authToken = try AuthToken.generate(for: createAccount)
    return authToken.save(on: request)
}


