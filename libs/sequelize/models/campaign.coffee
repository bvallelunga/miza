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
        isIn: [['cpm']]
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
    start_at: DataTypes.DATE
    end_at: {
      type: DataTypes.DATE
      validate: {
        isAfter: (end_date)->
          if @start_at and end_date < @start_at
            throw new Error "Campaign End Date must come after the Start Date"
      }
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
    
    instanceMethods: {
      utm_link: (link)->
        if link.indexOf("?") == -1
          link += "?"
        
        return link + [
          "utm_source=#{CONFIG.general.company.toLowerCase()}",
          "utm_medium=#{@type}"
          "utm_campaign=#{@name.split(" ").join("_").toLowerCase()}"
        ].join("&")
        
      
      create_transfer: ->
        Promise.props({
          advertiser: @getAdvertiser()
          industries: @getIndustries() 
        }).then (data)=>
          @industries = data.industries
          
          if @spend < 0.5
            return Promise.resolve()

          LIBS.models.Transfer.create({
            type: "charge"
            name: @name
            impressions: @impressions
            clicks: @clicks
            amount: @spend
            advertiser_id: @advertiser_id
            campaign_id: @id
            user_id: data.advertiser.owner_id
          })
    }
    
    validate: {
      notCompleted: ->            
        if @changed("status") and @previous("status") == "completed"
          throw new Error "A campaign's status can not be changed after it is complete."
    }
    hooks: {
      beforeCreate: (campaign)->
        campaign.impressions_needed = campaign.impressions_requested
        
            
      afterUpdate: (campaign)->
        if campaign.changed("status")
          Promise.resolve().then ->
            if campaign.status == "completed"
              campaign.create_transfer()
          
          .then ->
            campaign.getIndustries().each (industry)->
              if industry.status != "complete"              
                industry.status = campaign.status
                industry.save()
      
            
      beforeDestroy: (campaign)->
        Promise.resolve().then ->
          if campaign.status != "completed"
            campaign.create_transfer()
          
        .then ->
          campaign.getIndustries().each (industry)->
            industry.destroy()

    }
  }