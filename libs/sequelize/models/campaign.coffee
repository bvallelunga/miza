numeral = require "numeral"

module.exports = (sequelize, DataTypes)->

  return sequelize.define "Campaign", {
    name: { 
      type: DataTypes.STRING
      allowNull: false
    }
    type: {
      type: DataTypes.STRING
      allowNull: false
      validate: {
        isIn: [['standard']]
      }
    }
    status: {
      type: DataTypes.STRING
      allowNull: false
      validate: {
        isIn: [['running', 'paused', 'completed']]
      }
    }
    paid_at: DataTypes.DATE
    start_at: DataTypes.DATE
    end_at: {
      type: DataTypes.DATE
      validate: {
        isAfter: (end_date)->
          if @start_at and end_date < @start_at
            throw new Error "Campaign End Date must come after the Start Date"
      }
    }
    paid: {
      type: DataTypes.DECIMAL(13,2)
      defaultValue: 0
      allowNull: false
      get: ->      
        return Number @getDataValue("paid")
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
    refunded: {
      type: DataTypes.DECIMAL(13,2)
      defaultValue: 0
      allowNull: false
      get: ->      
        return Number @getDataValue("refunded")
    }
    budget: {
      type: DataTypes.VIRTUAL
      get: ->   
        total = 0
        
        if not @get("industries")?
          return total
        
        for industry in @get("industries")
          total += industry.budget
         
        return total
    }
    spend: {
      type: DataTypes.VIRTUAL
      get: ->      
        total = 0
        
        if not @get("industries")?
          return total
        
        for industry in @get("industries")
          total += industry.spend
         
        return total
    }
    metrics: {
      type: DataTypes.VIRTUAL
      get: ->      
        return {
          impressions: numeral(@get("impressions")).format("0[,]000")
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
        models.Campaign.belongsTo models.Advertiser, { 
          as: 'advertiser' 
        }
        
        models.Campaign.hasMany models.CampaignIndustry, { 
          as: 'industries' 
        }
        
        models.Campaign.hasMany models.Creative, { 
          as: 'creatives' 
        }
    }
    validate: {
      notCompleted: ->      
        if @changed("status") and @previous("status") == "completed"
          throw new Error "Campaign status can not be changed after it is complete."
    }
  }