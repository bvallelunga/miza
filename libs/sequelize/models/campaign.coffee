numeral = require "numeral"

module.exports = (sequelize, DataTypes)->

  return sequelize.define "Campaign", {
    name: { 
      type: DataTypes.STRING
      allowNull: false
    }
    active: {
      type: DataTypes.BOOLEAN
      defaultValue: false
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
        isIn: [['queued', 'running', 'paused', 'completed']]
      }
      set: (value)->
        @setDataValue("status", value)
        @setDataValue("active", value == "running")
        
        if value == "complete" and not @get("end_at")
          @setDataValue("end_at", new Date())
          
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
        
        if not @industries?
          return NaN
        
        for industry in @industries
          total += industry.budget
         
        return total
    }
    spend: {
      type: DataTypes.VIRTUAL
      get: ->      
        total = 0
        
        if not @industries?
          return NaN
        
        for industry in @industries
          total += industry.spend
         
        return total
    }
    progress: {
      type: DataTypes.VIRTUAL
      get: ->      
        total_requested = 0
        total_impressions = 0
        
        if not @industries?
          return NaN
        
        for industry in @industries
          total_requested += industry.impressions_requested
          total_impressions += industry.impressions
         
        return total_impressions/total_requested
    }
    metrics: {
      type: DataTypes.VIRTUAL
      get: ->      
        return {
          impressions: numeral(@impressions).format("0[,]000")
          clicks: numeral(@clicks).format("0[,]000")
          budget: numeral(@budget).format("$0[,]000.00")
          spend: numeral(@spend).format("$0[,]000.00")
          paid: numeral(@paid).format("$0[,]000.00")
          refunded: numeral(@refunded).format("$0[,]000.00")
          progress: numeral(@progress).format("0[.]0%")
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
    hooks: {      
      afterUpdate: (campaign)->
        if campaign.changed("status")
          campaign.getIndustries().each (industry)->
            if industry.status == "complete"
              return Promise.resolve()
            
            industry.status = campaign.status
            industry.save()
              
            
      beforeDestroy: (campaign)->
        campaign.getIndustries().each (industry)->
          industry.destroy()
          
    }
  }