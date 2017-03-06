numeral = require "numeral"

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
    metrics: {
      type: DataTypes.VIRTUAL
      get: ->      
        return {
          cpm: numeral(@get("cpm")).format("$0[,]000.00")
          impressions: numeral(@get("impressions")).format("0[,]000")
          impressions_needed: numeral(@get("impressions_needed")).format("0[,]000")
          impressions_requested: numeral(@get("impressions_requested")).format("0[,]000")
          clicks: numeral(@get("clicks")).format("0[,]000")
          budget: numeral(@get("budget")).format("$0[,]000.00")
          spend: numeral(@get("spend")).format("$0[,]000.00")
          paid: numeral(@get("paid")).format("$0[,]000.00")
          refunded: numeral(@get("refunded")).format("$0[,]000.00")
        }
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