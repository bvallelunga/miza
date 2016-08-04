Umzug = require 'umzug'

module.exports = (sequelize, models)->
  umzug = new Umzug {
    storage: 'sequelize'
    storageOptions: {
      sequelize: sequelize 
    }
    migrations: {
      params: [ sequelize, models ]
      path: __dirname
      pattern: /^(?!index).*\.coffee$/
    }
    logger: (message)-> 
      console.log "Sequelize Seeder: #{message}"
  }
    
  return umzug.up().then (response)-> 
    files = response.map (data)->
      return data.file
  
    if files.length > 0
      console.log "Sequelize Seeder: #{files}"