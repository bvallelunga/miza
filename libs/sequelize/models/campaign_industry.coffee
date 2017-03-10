numeral = require "numeral"

module.exports = (sequelize, DataTypes)->

  return sequelize.define "CampaignIndustry", {
    active: {
      type: DataTypes.BOOLEAN
      defaultValue: false
    }
    status: {
      type: DataTypes.STRING
      allowNull: false
      validate: {
        isIn: [['queued', 'running', 'paused', 'completed']]
      }
      set: (value)->
        @setDataValue("status", value)
        @setDataValue("active", value == "running")
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
        return @cpm_impression * @impressions_requested
    }
    spend: {
      type: DataTypes.VIRTUAL
      get: ->      
        return @cpm_impression * @impressions
    }
    cpm_impression: {
      type: DataTypes.VIRTUAL
      get: ->      
        return @cpm / 1000
    }
    progress: {
      type: DataTypes.VIRTUAL
      get: ->      
        return @impressions/@impressions_requested
    }
    ctr: {
      type: DataTypes.VIRTUAL
      get: ->      
        return @clicks/Math.max(@impressions or 1)
    }
    metrics: {
      type: DataTypes.VIRTUAL
      get: ->      
        return {
          cpm: numeral(@cpm).format("$0[,]000.00")
          impressions: numeral(@impressions).format("0[,]000")
          impressions_needed: numeral(@impressions_needed).format("0[,]000")
          impressions_requested: numeral(@impressions_requested).format("0[,]000")
          clicks: numeral(@clicks).format("0[,]000")
          budget: numeral(@budget).format("$0[,]000.00")
          spend: numeral(@spend).format("$0[,]000.00")
          progress: numeral(@progress).format("0[.]0%")
          ctr: numeral(@ctr).format("0[.]0%")
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
      beforeCreate: (campaignIndustry)->
        campaignIndustry.impressions_needed = campaignIndustry.impressions_requested
        
    }
    
    validate: {
      notCompleted: ->            
        if @changed("status") and @previous("status") == "completed"
          throw new Error "Industry status can not be changed after it is complete."
    }
  }