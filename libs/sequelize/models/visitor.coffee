request = require "request-promise"

module.exports = (sequelize, DataTypes)->

  return sequelize.define "Visitor", {
    identifier: { 
      type: DataTypes.STRING
      allowNull: false
      unique: true
    }
    device: { 
      type: DataTypes.STRING
      allowNull: false
      validate: {
        isIn: {
          args: [['mobile', 'table', 'desktop', 'tv']]
          msg: "Invalid device type."
        }
      }
    }
    data: {
      type: DataTypes.JSONB
      defaultValue: {}
    }
    mobile: {
      type: DataTypes.JSONB
      defaultValue: {}
    }
    desktop: {
      type: DataTypes.JSONB
      defaultValue: {}
    }
    user: {
      type: DataTypes.JSONB
      defaultValue: {}
    }
    location: {
      type: DataTypes.JSONB
      defaultValue: {}
    }
    config: {
      type: DataTypes.JSONB
      defaultValue: {}
    }
  }, {    
    classMethods: {      
      associate: (models)->        
        models.Visitor.belongsTo models.Publisher, { 
          as: 'publisher' 
        }
        
    }
    
  }