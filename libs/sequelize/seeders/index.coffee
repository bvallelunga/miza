fs        = require 'fs'
path      = require 'path'
basename  = path.basename module.filename 

module.exports = (sequelize, models)-> 
  sequelize.sync({ force: false }).then ->  
    fs.readdirSync(__dirname).filter (file)->
      return file != basename and file.split(".").slice(-1)[0] == 'coffee'
    
    .forEach (file)->
      require("#{__dirname}/#{file}")(sequelize, models)