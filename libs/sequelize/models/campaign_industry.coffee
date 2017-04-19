numeral = require "numeral"

module.exports = (sequelize, DataTypes)->

  return sequelize.define "CampaignIndustry", {
    active: {
      type: DataTypes.BOOLEAN
      defaultValue: false
    }
    type: {
      type: DataTypes.STRING
      allowNull: false
      validate: {
        isIn: [['cpm', 'cpc']]
      }
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
    amount: {
      type: DataTypes.DECIMAL(6,3)
      defaultValue: 0
      allowNull: false
      validate: {
        min: {
          args: [ 0 ]
          msg: "Amount must be greater than or equal to 0"
        }
      }
      get: ->      
        return Number @getDataValue("amount")
    }
    model_cost: {
      type: DataTypes.VIRTUAL
      get: ->   
        if @type == "cpm" 
          return @amount / 1000 
          
        return @amount
    }
    spend: {
      type: DataTypes.VIRTUAL
      get: ->    
        if @type == "cpm"
          return @model_cost * @impressions
          
        else if @type == "cpc"
          return @model_cost * @clicks
          
        return 0
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
          amount: numeral(@amount).format("$0[,]000.00")
          impressions: numeral(@impressions).format("0[,]000")
          clicks: numeral(@clicks).format("0[,]000")
          budget: numeral(@budget).format("$0[,]000.00")
          spend: numeral(@spend).format("$0[,]000.00")
          ctr: numeral(@ctr).format("0[.]00%")
        }
    }
    config: {
      type: DataTypes.JSONB
      defaultValue: {}
    }
    targeting: {
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
        campaignIndustry.targeting = {
          devices: campaignIndustry.targeting.devices or null
          os: campaignIndustry.targeting.os or null
          countries: campaignIndustry.targeting.countries or null
          browsers: campaignIndustry.targeting.browsers or null
          days: campaignIndustry.targeting.days or null
          blocked_publishers: []
        }
        
        
      beforeUpdate: (campaignIndustry)->
        if campaignIndustry.changed("status") and campaignIndustry.previous("status") == "completed"
          campaignIndustry.status = "completed"

    }
  }