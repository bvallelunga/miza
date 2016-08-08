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
    define: {
      paranoid: true
      underscored: true 
      freezeTableName: true
    }
  })

  database = {
    sequelize: sequelize
    Sequelize: Sequelize
  }

  models = require("./models")(sequelize)  
  require("./migrations")(sequelize).then ->
    console.log "Sequelize Sync: #{ Object.keys(models).join(", ") }"
    return sequelize.sync({ force: false })
    
  .then ->
    require("./seeders")(sequelize, models)
  
  return Object.assign(database, models)