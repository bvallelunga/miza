module.exports = (sequelize, DataTypes)->
  
  return sequelize.define "IndustryAudit", {
    name: DataTypes.STRING
    fee: {
      type: DataTypes.DECIMAL(4,3)
      allowNull: false
      get: ->      
        return Number @getDataValue("fee")
        
    }
    cpc: {
      type: DataTypes.DECIMAL(6,3)
      allowNull: false
      get: ->      
        return Number @getDataValue("cpc")
    
    }
    cpm: {
      type: DataTypes.DECIMAL(6,3)
      allowNull: false
      get: ->      
        return Number @getDataValue("cpm")
        
    }
  }