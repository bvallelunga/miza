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
    cpc: {
      type: DataTypes.DECIMAL(6,3)
      defaultValue: 0
      allowNull: false
      validate: {
        min: {
          args: [ 0 ]
          msg: "CPC must be greater than or equal to 0"
        }
      }
      get: ->      
        return Number @getDataValue("cpc")
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
      listed: (is_admin)->
        query = {
          max_impressions: {
            $gt: 0
          }
        }
        
        if not is_admin
          query.private = false
      
        LIBS.models.Industry.findAll({
          where: query
          order: [
            ['name', 'ASC']
          ]
        })
    }
    hooks: {            
      afterUpdate: (industry)->                     
        LIBS.models.IndustryAudit.create({
          name: industry.previous "name"
          cpm: industry.previous "cpm"
          cpc: industry.previous "cpc"
          private: industry.previous "private"
          max_impressions: industry.previous "max_impressions"
          industry_id: industry.id
        })

    }
  }