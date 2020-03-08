import FluentPostgreSQL
import Vapor
import Authentication

/// Called before your application initializes.
public func configure(_ config: inout Config, _ env: inout Environment, _ services: inout Services) throws {
    // Register providers first
    try services.register(FluentPostgreSQLProvider())
    try services.register(AuthenticationProvider())
    // Register routes to the router
    let router = EngineRouter.default()
    try routes(router)
    services.register(router, as: Router.self)
    
    // Register middleware
    var middlewares = MiddlewareConfig() // Create _empty_ middleware config
    let corsConfiguration = CORSMiddleware.Configuration(
        allowedOrigin: .custom("http://localhost:3000"),
        allowedMethods: [.GET, .POST, .OPTIONS, .DELETE, .PATCH],
        allowedHeaders: [.accept, .authorization, .contentType, .origin, .xRequestedWith, .userAgent, .accessControlAllowOrigin])
    let corsMiddleware = CORSMiddleware(configuration: corsConfiguration)
    middlewares.use(corsMiddleware)
    middlewares.use(ErrorMiddleware.self) // Catches errors and converts to HTTP response
    services.register(middlewares)
    
    //Configure remote DB
    let database: String
    let port: Int
    
    if env == .testing {
        database = "incord-test"
        port = 5433
    } else {
        database = "incord"
        port = 5432
    }
    
    let hostname = Environment.get("DATABASE_HOSTNAME") ?? "localhost"
    let username = Environment.get("DATABASE_USERNAME") ?? "cartisim"
    //    let password = Environment.get("DATABASE_PASSWORD") ?? "password"
    
    // Configure a Postgres database
    let databaseConfig = PostgreSQLDatabaseConfig(hostname: hostname, port: port, username: username, database: database)
    let psql = PostgreSQLDatabase(config: databaseConfig)
    
    // Register the configured PSQL database to the database config.
    var databases = DatabasesConfig()
    databases.add(database: psql, as: .psql)
    services.register(databases)
    
    // Configure migrations
    var migrations = MigrationConfig()
    migrations.add(model: CreateAccount.self, database: .psql)
    migrations.add(model: SubChannel.self, database: .psql)
    migrations.add(model: Message.self, database: .psql)
    migrations.add(model: Channel.self, database: .psql)
    migrations.add(model: ChannelImage.self, database: .psql)
    migrations.add(model: AuthToken.self, database: .psql)
    migrations.add(migration: AdminAccount.self, database: .psql)
    services.register(migrations)
    
     //Configure Vapors commands
    var commandConfig = CommandConfig.default()
    commandConfig.useFluentCommands()
    services.register(commandConfig)
    
    //We need to expand the byte size for sending requests
    services.register(NIOServerConfig.default(maxBodySize: 20_000_000))
     
    // Create a new NIO websocket server
    let wss = NIOWebSocketServer.default()
    try socketRouter(wss)
    // Register our server
    services.register(wss, as: WebSocketServer.self)
}
