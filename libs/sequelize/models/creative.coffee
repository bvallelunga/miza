request = require "request"

module.exports = (sequelize, DataTypes)->

  return sequelize.define "Creative", {
    link: { 
      type: DataTypes.STRING
      allowNull: false
    }
    description: DataTypes.STRING
    title: DataTypes.STRING
    image: { 
      type: DataTypes.BLOB("long")
      allowNull: false
    }
    trackers: {
      type: DataTypes.JSONB
      defaultValue: []
    }
    config: {
      type: DataTypes.JSONB
      defaultValue: {}
    }
  }, {    
    classMethods: {      
      associate: (models)->        
        models.Creative.belongsTo models.Advertiser, { 
          as: 'advertiser' 
        }
        
        models.Creative.belongsTo models.Campaign, { 
          as: 'campaign' 
        }

    }
  }