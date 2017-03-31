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
    pool: {
      max: 1
      min: 0
      idle: 10000
    }
  })

  database = {
    sequelize: sequelize
    Sequelize: Sequelize
  }

  models = require("./models")(sequelize)  
  require("./migrations")(sequelize, models).then ->
    return sequelize.sync({ force: false })
    
  .then ->
    require("./seeders")(sequelize, models)

  .then ->
    require("./defaults")(models)
  
  .then ->
    return Object.assign(database, models)