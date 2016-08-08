module.exports = (sequelize, DataTypes)->
  
  return sequelize.define "IndustryAudit", {
    name: DataTypes.STRING
    type: { 
      type: DataTypes.ENUM("cpm", "cpc")
      allowNull: false
    }
    cost: {
      type: DataTypes.DECIMAL(5,3)
      allowNull: false
      get: ->      
        return Number @getDataValue("cost")
        
    }
  }