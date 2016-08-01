Sequelize = require "sequelize"
database  = null

# Exports
module.exports = ->
  if database?
    return database

  sequelize  = new Sequelize(CONFIG.postgres_url, { 
    dialectOptions: {
      ssl: true
    }
  })
  
  migrations = require("./migrations")(sequelize) 
  database   = require("./models")(sequelize)
  
  database.sequelize = sequelize
  database.Sequelize = sequelize
  
  return database