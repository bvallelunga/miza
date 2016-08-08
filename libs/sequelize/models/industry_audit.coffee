module.exports = (sequelize, DataTypes)->
  
  return sequelize.define "IndustryAudit", {
    name: DataTypes.STRING
    type: { 
      type: DataTypes.ENUM("cpm", "cpc")
      allowNull: false
    }
    cut: {
      type: DataTypes.DECIMAL(4,3)
      allowNull: false
      get: ->      
        return Number @getDataValue("cut")
        
    }
    cost: {
      type: DataTypes.DECIMAL(6,3)
      allowNull: false
      get: ->      
        return Number @getDataValue("cost")
        
    }
  }