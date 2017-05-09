Umzug = require 'umzug'
Knex  = require 'knex'
URL   = require 'url'

module.exports = (sequelize, models)->
  pg_server = URL.parse CONFIG.postgres.url
  knex = Knex({
    client: "postgresql"
    connection: {
      host: pg_server.hostname
      port: pg_server.port
      user: if pg_server.auth? then pg_server.auth.split(':')[0] else ""
      password: if pg_server.auth? then pg_server.auth.split(':')[1] else null
      database: pg_server.path.substring(1)
      ssl: CONFIG.postgres.ssl
    }
  })

  umzug = new Umzug {
    storage: 'sequelize'
    storageOptions: {
      sequelize: sequelize 
    }
    migrations: {
      params: [ knex, models ]
      path: "#{__dirname}/pending"
    }
    logger: (message)-> 
      console.log "Sequelize Migration: #{message}"
  }
  
  return umzug.up().then (response)-> 
    files = response.map (data)->
      return data.file
    
    if files.length > 0
      console.log """
      Sequelize Migration
      -----------------------
      #{files.join("\n")}
      -----------------------
      """
    