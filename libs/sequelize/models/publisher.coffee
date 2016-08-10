url = require 'url'
randomstring = require "randomstring"

module.exports = (sequelize, DataTypes)->

  return sequelize.define "Publisher", {
    name: { 
      type: DataTypes.STRING,
      allowNull: false
    }
    domain: { 
      type: DataTypes.STRING,
      unique: true
      allowNull: false
      validate: {
        isUrl: {
          msg: "Must be valid domain name"
        }
      }
      set: (value)->
        value = @extract_domain value
        @setDataValue 'domain', value 
        @setDataValue 'endpoint', "#{@key}.#{value.split(".").slice(-2).join(".")}"
    }
    endpoint: {
      type: DataTypes.STRING,
      unique: true
      allowNull: false
      validate: {
        isUrl: {
          msg: "Must be valid endpoint name"
        }
      }
    }
    key: { 
      type: DataTypes.STRING,
      unique: true
      allowNull: false
    }
    is_demo: {
      type: DataTypes.BOOLEAN
      defaultValue: false
    }
    coverage_ratio: {
      type: DataTypes.DECIMAL(3,2)
      defaultValue: 1
      validate: {
        min: {
          args: [ 0 ]
          msg: "Coverage must be greater than or equal to 0%"
        }
        max: {
          args: [ 1 ]
          msg: "Coverage must be less than or equal to 100%"
        }
      }
      get: ->      
        return Number @getDataValue("coverage_ratio")
        
    }
  }, {    
    classMethods: {      
      associate: (models)->
        models.Publisher.belongsToMany models.User, {
          as: 'members'
          through: "UserPublisher"
        }
        
        models.Publisher.hasMany(models.Event, { 
          as: 'events' 
        })
        
        models.Publisher.belongsTo(models.Industry, { 
          as: 'industry' 
        })

    }
    instanceMethods: {
      extract_domain: (website)->
        domain = url.parse website.toLowerCase()
        hostname = (domain.hostname || domain.pathname).split(".").slice(-2).join(".")
        return "#{hostname}#{if domain.port? then (":" + domain.port) else "" }"
      
      heroku_add_domain: (domain)->
        LIBS.heroku.post "/apps/#{CONFIG.app_name}/domains", {
          body: { hostname: domain }
        } 
        
      heroku_remove_domain: (domain)->
        LIBS.heroku.delete "/apps/#{CONFIG.app_name}/domains/#{domain}"
 
    }
    hooks: {
      beforeValidate: (publisher, options)->
        if not publisher.key?
          publisher.key = randomstring.generate({
            length: 15
            charset: 'alphabetic'
          }).toLowerCase()
          publisher.endpoint = "#{publisher.key}.#{publisher.domain}"
          
      
#       afterCreate: (publisher, options, callback)->
#         publisher.heroku_add_domain(publisher.endpoint).then ->
#           callback()
#         .catch console.warn
# 
#         
#       afterUpdate: (publisher, options, callback)->
#         if publisher.endpoint != publisher.previous("endpoint")
#           publisher.heroku_add_domain(publisher.endpoint).then ->
#             callback()
#           .catch console.warn

    }
  }