Umzug     = require 'umzug'
fs        = require 'fs'
path      = require 'path'
basename  = path.basename module.filename 

module.exports = (sequelize)->
  umzug = new Umzug {
    storage: 'sequelize'
    storageOptions: {
      sequelize: sequelize 
    }
    path: __dirname
    pattern: /^\d+[\w-]+\.coffee$/
  }
  
  migrations = fs.readdirSync(__dirname).filter (file)->
    return file != basename and file.split(".").slice(-1)[0] == 'coffee'
  
  .map (file)->
    return path.basename file, ".coffee"
  
  return umzug.execute({
    migrations: migrations,
    method: 'up'
  })