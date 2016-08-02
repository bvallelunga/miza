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
        this.setDataValue 'domain', value 
        this.setDataValue 'endpoint', "#{this.key}.#{value}"
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
  }, {
    paranoid: true,
    underscored: true
    
    classMethods: {
      associate: (models)->
        models.Publisher.belongsToMany models.User, {
          as: 'Members'
          through: "UserPublisher"
        }
    }
    instanceMethods: {
      add_domain: (domain)->
        LIBS.heroku.post "/apps/#{CONFIG.app_name}/domains", {
          body: { hostname: domain }
        } 
        
      remove_domain: (domain)->
        LIBS.heroku.delete "/apps/#{CONFIG.app_name}/domains/#{domain}"
 
    }
    hooks: {
      beforeValidate: (publisher, options)->
        if not publisher.key?
          publisher.key = Math.random().toString(36).substr(2, 10)
          publisher.endpoint = "#{publisher.key}.#{publisher.domain}"
          
      
      afterCreate: (publisher)->
        publisher.add_domain(publisher.endpoint).catch console.warn

        
      afterUpdate: (publisher)->
        publisher.add_domain(publisher.endpoint).catch console.warn
        publisher.remove_domain(publisher.previous "endpoint").catch console.warn

    }
  }