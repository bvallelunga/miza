module.exports = (sequelize, DataTypes)->
  
  return sequelize.define "Industry", {
    name: DataTypes.STRING
    type: { 
      type: DataTypes.ENUM("cpm", "cpc")
      allowNull: false
    }
    cut: {
      type: DataTypes.DECIMAL(4,3)
      defaultValue: 0
      validate: {
        min: {
          args: [ 0 ]
          msg: "Cut must be greater than or equal to 0%"
        }
        max: {
          args: [ 1 ]
          msg: "Cut must be less than or equal to 100%"
        }
      }
      get: ->      
        return Number @getDataValue("cut")
        
    }
    cost: {
      type: DataTypes.DECIMAL(6,3)
      defaultValue: 0
      validate: {
        min: {
          args: [ 0 ]
          msg: "Cost must be greater than or equal to 0"
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
          cut: industry.previous "cut"
        }

    }
  }