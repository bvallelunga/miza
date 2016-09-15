Sequelize = require "sequelize"

# Exports
module.exports = ->
  sequelize  = new Sequelize(CONFIG.postgres.url, { 
    logging: false
    dialectOptions: {
      ssl: CONFIG.postgres.ssl
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
  
  .then ->
    return Object.assign(database, models)