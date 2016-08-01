Sequelize = require "sequelize"
database  = null

# Exports
module.exports = ->
  if database?
    return database

  sequelize  = new Sequelize(CONFIG.postgres_url, { 
    logging: false
    dialectOptions: {
      ssl: true
    }
  })
  
  migrations = require("./migrations")(sequelize) 
  database   = require("./models")(sequelize)
  
  require("./seeders")(sequelize, database)
  
  database.sequelize = sequelize
  database.Sequelize = sequelize
  
  return database