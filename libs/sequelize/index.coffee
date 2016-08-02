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
  
  database = require("./models")(sequelize)
  
  require("./migrations")(sequelize).then ->
    return sequelize.sync({ force: false })
    
  .then ->
    require("./seeders")(sequelize, database)
  
  database.sequelize = sequelize
  database.Sequelize = sequelize
  
  return database