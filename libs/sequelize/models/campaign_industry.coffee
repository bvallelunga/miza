module.exports = (sequelize, DataTypes)->

  return sequelize.define "CampaignIndustry", {
    active: {
      type: DataTypes.BOOLEAN
      defaultValue: true
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
          as: 'industy' 
        }

    }
  }