module.exports = (sequelize, DataTypes)->
  
  return sequelize.define "IndustryAudit", {
    name: DataTypes.STRING
    cpm: {
      type: DataTypes.DECIMAL(6,3)
      allowNull: false
      get: ->      
        return Number @getDataValue("cpm")
    
    }
    max_impressions: {
      defaultValue: 0
      allowNull: false
      type: DataTypes.DECIMAL(13)
      get: ->      
        return Number @getDataValue("max_impressions")
    }
    private: { 
      type: DataTypes.BOOLEAN
      defaultValue: false
    }
  }, {    
    classMethods: {      
      associate: (models)->    
        models.IndustryAudit.belongsTo models.Industry, { 
          as: 'industry' 
        }

    }
  }