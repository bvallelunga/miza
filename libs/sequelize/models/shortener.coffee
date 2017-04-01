randomstring = require "randomstring"

module.exports = (sequelize, DataTypes)->

  return sequelize.define "Shortener", {
    name: { 
      type: DataTypes.STRING
      allowNull: false
    }
    key: { 
      type: DataTypes.STRING
      unique: true
      allowNull: false
    }
    url: { 
      type: DataTypes.STRING
      allowNull: false
      get: ->
        return "#{@getDataValue("url")}#m-creative=#{@creative_id}"
    }
  }, {    
    classMethods: {      
      associate: (models)->
        models.Shortener.belongsTo models.User, { 
          as: 'owner' 
        }
        
        models.Shortener.belongsTo models.Creative, {
          as: 'creative'
        }

    }
    hooks: {
      beforeValidate: (advertiser)->
        if not advertiser.key?
          advertiser.key = randomstring.generate({
            length: 6
            charset: 'alphabetic'
          }).toLowerCase()
    }
  
  }