module.exports = (sequelize, DataTypes)->
  
  return sequelize.define "IndustryAudit", {
    name: DataTypes.STRING
    cpm: {
      type: DataTypes.DECIMAL(6,3)
      allowNull: false
      get: ->      
        return Number @getDataValue("cpm")
        
    }
    private: { 
      type: DataTypes.BOOLEAN
      defaultValue: false
    }
  }