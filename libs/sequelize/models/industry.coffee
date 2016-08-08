module.exports = (sequelize, DataTypes)->
  
  return sequelize.define "Industry", {
    name: DataTypes.STRING
    type: { 
      type: DataTypes.ENUM("cpm", "cpc")
      allowNull: false
    }
    cost: {
      type: DataTypes.DECIMAL(5,3)
      defaultValue: 0
      validate: {
        min: {
          args: [ 0 ]
          msg: "Value must be greater than or equal to 0"
        }
      }
      get: ->      
        return Number @getDataValue("cost")
        
    }
  }, {
    hooks: {
      afterUpdate: (industry)->
        LIBS.models.IndustryAudit.create {
          name: industry.previous "name"
          type: industry.previous "type"
          cost: industry.previous "cost"
        }

    }
  }