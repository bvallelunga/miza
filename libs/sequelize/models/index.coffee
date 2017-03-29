fs        = require 'fs'
path      = require 'path'
basename  = path.basename module.filename 
models    = null

module.exports = (sequelize)->
  return models if models?
  
  models = {}
  
  fs.readdirSync(__dirname).filter( (file)->
    return file != basename and file.split(".").slice(-1)[0] == 'coffee'
  ).forEach (file)->
    model = sequelize['import'](path.join(__dirname, file))
    models[model.name] = model
  
  Object.keys(models).forEach (modelName)->
    if models[modelName].associate?
      models[modelName].associate models
      
    if models[modelName].keen_datasets? 
      models[modelName].keen_datasets models
        
  return models