module.exports = (sequelize, DataTypes)->
  
  return sequelize.define "Industry", {
    name: DataTypes.STRING
    cpm: {
      type: DataTypes.DECIMAL(6,3)
      defaultValue: 0
      allowNull: false
      validate: {
        min: {
          args: [ 0 ]
          msg: "CPM must be greater than or equal to 0"
        }
      }
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
      listed: ->
        LIBS.models.Industry.findAll({
          where: {
            private: false
          }
        })
    }
    hooks: {            
      afterUpdate: (industry)->                     
        LIBS.models.IndustryAudit.create({
          name: industry.previous "name"
          cpm: industry.previous "cpm"
          private: industry.previous "private"
          industry_id: industry.id
        })

    }
  }