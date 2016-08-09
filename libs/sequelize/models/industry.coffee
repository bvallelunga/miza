module.exports = (sequelize, DataTypes)->
  
  return sequelize.define "Industry", {
    name: DataTypes.STRING
    fee: {
      type: DataTypes.DECIMAL(4,3)
      defaultValue: 0
      validate: {
        min: {
          args: [ 0 ]
          msg: "Fee must be greater than or equal to 0%"
        }
        max: {
          args: [ 1 ]
          msg: "Fee must be less than or equal to 100%"
        }
      }
      get: ->      
        return Number @getDataValue("fee")
        
    }
    cpm: {
      type: DataTypes.DECIMAL(6,3)
      defaultValue: 0
      validate: {
        min: {
          args: [ 0 ]
          msg: "CPM must be greater than or equal to 0"
        }
      }
      get: ->      
        return Number @getDataValue("cpm")

    }  
    cpc: {
      type: DataTypes.DECIMAL(6,3)
      defaultValue: 0
      validate: {
        min: {
          args: [ 0 ]
          msg: "CPC must be greater than or equal to 0"
        }
      }
      get: ->      
        return Number @getDataValue("cpc")
        
    }
  }, {
    hooks: {            
      afterUpdate: (industry, options, callback)->               
        LIBS.models.IndustryAudit.create({
          name: industry.previous "name"
          cpm: industry.previous "cpm"
          cpc: industry.previous "cpc"
          fee: industry.previous "fee"
        }).then ->
          callback()
          
        .catch callback

    }
  }