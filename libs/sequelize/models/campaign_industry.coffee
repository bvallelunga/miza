module.exports = (sequelize, DataTypes)->

  return sequelize.define "CampaignIndustry", {
    active: {
      type: DataTypes.BOOLEAN
      defaultValue: false
    }
    impressions_requested: {
      type: DataTypes.DECIMAL(15)
      defaultValue: 0
      get: ->      
        return Number @getDataValue("impressions_requested")
    }
    impressions_needed: {
      type: DataTypes.DECIMAL(15)
      defaultValue: 0
      get: ->      
        return Number @getDataValue("impressions_needed")
    }
    impressions: {
      type: DataTypes.DECIMAL(15)
      defaultValue: 0
      get: ->      
        return Number @getDataValue("impressions")
    }
    clicks: {
      type: DataTypes.DECIMAL(15)
      defaultValue: 0
      get: ->      
        return Number @getDataValue("clicks")
    }
    paid: {
      type: DataTypes.DECIMAL(13,2)
      defaultValue: 0
      allowNull: false
      get: ->      
        return Number @getDataValue("paid")
    }
    refunded: {
      type: DataTypes.DECIMAL(13,2)
      defaultValue: 0
      allowNull: false
      get: ->      
        return Number @getDataValue("refunded")
    }
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
    budget: {
      type: DataTypes.VIRTUAL
      get: ->      
        return @get("cpm_impression") * @get("impressions_requested")
    }
    spend: {
      type: DataTypes.VIRTUAL
      get: ->      
        return @get("cpm_impression") * @get("impressions")
    }
    cpm_impression: {
      type: DataTypes.VIRTUAL
      get: ->      
        return @get("cpm") / 1000
    }
    config: {
      type: DataTypes.JSONB
      defaultValue: {}
    }
  }, {    
    classMethods: {      
      associate: (models)->        
        models.CampaignIndustry.belongsTo models.Advertiser, { 
          as: 'advertiser' 
        }
        
        models.CampaignIndustry.belongsTo models.Campaign, { 
          as: 'campaign' 
        }
        
        models.CampaignIndustry.belongsTo models.Industry, { 
          as: 'industry' 
        }  
    }
    hooks: {
      beforeValidate: (campaignIndustry)->
        campaignIndustry.impressions_needed = campaignIndustry.impressions_requested - campaignIndustry.impressions
          
    }
  }