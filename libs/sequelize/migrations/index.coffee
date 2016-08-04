Umzug = require 'umzug'
Knex  = require 'knex'
URL   = require 'url'

module.exports = (sequelize, models)->
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
      pattern: /^(?!index).*\.coffee$/
    }
    logger: (message)-> 
      console.log "Sequelize Migration: #{message}"
  }
  
  return umzug.up().then (response)-> 
    files = response.map (data)->
      return data.file
    
    if files.length > 0
      console.log "Sequelize Migration: #{files}"
    