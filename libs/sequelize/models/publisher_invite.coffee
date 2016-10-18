randomstring = require "randomstring"

module.exports = (sequelize, DataTypes)->

  return sequelize.define "PublisherInvite", {
    source: { 
      type: DataTypes.STRING,
      allowNull: false
    }
    data: {
      type: DataTypes.JSONB
      defaultValue: {}
    }
    key: { 
      type: DataTypes.STRING,
      unique: true
      allowNull: false
    }
  }, {    
    classMethods: {      
      associate: (models)->
        models.PublisherInvite.belongsTo models.Publisher, { 
          as: 'publisher' 
        }
        
    }
    hooks: {
      beforeValidate: (invite)->
        if not invite.key?
          invite.key = randomstring.generate({
            length: Math.floor(Math.random() * 4) + 4
            charset: 'alphabetic'
          }).toLowerCase()   
    }
  }