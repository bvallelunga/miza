Umzug     = require 'umzug'
Knex      = require 'knex'
URL       = require 'url'
fs        = require 'fs'
path      = require 'path'
basename  = path.basename module.filename 


module.exports = (sequelize)->
  pg_server = URL.parse CONFIG.postgres_url
  knex = Knex({
    client: "postgresql"
    connection: {
      host: pg_server.hostname
      port: pg_server.port
      user: pg_server.auth.split(':')[0]
      password: pg_server.auth.split(':')[1]
      database: pg_server.path.substring(1)
      ssl: true
    }
  })

  umzug = new Umzug {
    storage: 'sequelize'
    storageOptions: {
      sequelize: sequelize 
    }
    migrations: {
      params: [ knex ]
      path: __dirname
      pattern: /^\d+[\w-]+\.coffee$/
    }
  }
  
  migrations = fs.readdirSync(__dirname).filter (file)->
    return file != basename and file.split(".").slice(-1)[0] == 'coffee'
  
  .map (file)->
    return path.basename file, ".coffee"
  
  return umzug.execute({
    migrations: migrations,
    method: 'up'
  })