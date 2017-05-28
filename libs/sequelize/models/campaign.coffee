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
        isIn: {
          args: [['cpm', 'cpc']]
          msg: "Invalid campaign type."
        }
      }
    }
    status: {
      type: DataTypes.STRING
      allowNull: false
      validate: {
        isIn: {
          msg: "Invalid campaign status."
          args: [['pending', 'queued', 'running', 'paused', 'completed', 'rejected']]
        }
      }
      set: (value)->
        @setDataValue("status", value)
        @setDataValue("active", value == "running")
        
        if value == "complete" and not @get("end_at")
          @setDataValue("end_at", new Date())
          
    }
    start_at: DataTypes.DATE
    transferred_at: DataTypes.DATE
    end_at: {
      type: DataTypes.DATE
      validate: {
        isAfter: (end_date)->
          if @start_at and end_date < @start_at
            throw new Error "Campaign End Date must come after the Start Date"
      }
    }
    quantity_requested: {
      type: DataTypes.DECIMAL(15)
      defaultValue: 0
      get: ->      
        return Number @getDataValue("quantity_requested")
    }
    quantity_needed: {
      type: DataTypes.DECIMAL(15)
      defaultValue: 0
      get: ->      
        return Number @getDataValue("quantity_needed")
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
        return Number(@getDataValue("amount"))
    }
    credits: {
      type: DataTypes.DECIMAL(6,3)
      defaultValue: 0
      allowNull: false
      get: ->      
        return Number @getDataValue("credits")
    }
    model_cost: {
      type: DataTypes.VIRTUAL
      get: ->   
        if @type == "cpm" 
          return @amount / 1000 
          
        return @amount
    }
    budget: {
      type: DataTypes.VIRTUAL
      get: ->
        return @model_cost * @quantity_requested
    }
    spend: {
      type: DataTypes.VIRTUAL
      get: -> 
        cost = 0
           
        if @type == "cpm"
          cost = @model_cost * @impressions
          
        else if @type == "cpc"
          cost = @model_cost * @clicks
          
        return Math.max(0, cost - @credits)
    }
    progress: {
      type: DataTypes.VIRTUAL
      get: ->
        model = 0
        
        if @type == "cpm" 
          model = @impressions 
          
        else if @type == "cpc" 
          model = @clicks
               
        return model/@quantity_requested
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
          credits: numeral(@credits).format("$0[,]000.00")
          amount: numeral(@amount).format("$0[,]000.00")
          impressions: numeral(@impressions).format("0[,]000")
          quantity_needed: numeral(@quantity_needed).format("0[,]000")
          quantity_requested: numeral(@quantity_requested).format("0[,]000")
          clicks: numeral(@clicks).format("0[,]000")
          budget: numeral(@budget).format("$0[,]000.00")
          spend: numeral(@spend).format("$0[,]000.00")
          progress: numeral(@progress).format("0[.]00%")
          ctr: numeral(@ctr).format("0[.]00%")
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
        
        models.Campaign.hasOne models.Transfer, { 
          as: 'transfer' 
        } 
      
      keen_datasets: ->
        Promise.resolve([
          {
            timezone: "UTC"
            dataset_name: "campaign-impression-chart"
            display_name: "Campaign Impression Chart"
            analysis_type: "count"
            event_collection : "ads.event.impression"
            timeframe: "this_3_months"
            interval: "every_5_hours"
          }
          {
            timezone: "UTC"
            dataset_name: "campaign-click-chart"
            display_name: "Campaign Click Chart"
            analysis_type: "count"
            event_collection : "ads.event.click"
            timeframe: "this_3_months"
            interval: "every_5_hours"
          }
          {
            timezone: "UTC"
            dataset_name: "campaign-publisher-impression-count"
            display_name: "Campaign Publisher Impression Count"
            analysis_type: "count"
            event_collection : "ads.event.impression"
            timeframe: "this_3_months"
            interval: "every_5_hours"
            group_by: [
              "publisher.key"
            ]
          }
          {
            timezone: "UTC"
            dataset_name: "campaign-publisher-click-count"
            display_name: "Campaign Publisher Click Count"
            analysis_type: "count"
            event_collection : "ads.event.click"
            timeframe: "this_3_months"
            interval: "every_5_hours"
            group_by: [
              "publisher.key"
            ]
          }
        ]).each (query)->
          LIBS.keen.createDataset(query.dataset_name, {
            display_name: query.display_name
            query: query
            index_by: ["campaign.id"]
          })       
    }
    
    instanceMethods: {
      email_status: (email_type)->        
        campaign = @
        
        @getAdvertiser({
          include: [{
            model: LIBS.models.User
            as: "members"
            where: {
              is_admin: false
            }
          }]
        }).then (advertiser)->
          LIBS.emails.send email_type, advertiser.members.map (user)->
            return {
              to: user.email
              host: CONFIG.web_server.host
              data: {
                user: user
                campaign: campaign
                advertiser: advertiser
              }
            }
          
          .catch console.log

      
      utm_link: (link)->        
        link += if link.indexOf("?") == -1 then "?" else "&"
        
        return link + [
          "utm_source=#{CONFIG.general.company.toLowerCase()}",
          "utm_medium=#{@type}"
          "utm_campaign=#{@name.split(" ").join("_").toLowerCase()}"
        ].join("&")
        
      
      create_transfer: ->
        @getAdvertiser().then (advertiser)=>       
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
            user_id: advertiser.owner_id
          })
          
        .then =>
          @transferred_at = new Date()
          @save()

    }
    
    validate: {
      notCompleted: ->            
        if @changed("status")
          if @previous("status") == "completed"
            throw new Error "Completed campaigns can not be changed."
           
          if @previous("status") == "rejected" and not @admin_override and @status != "completed"
            throw new Error "Rejected campaigns can not be changed."
           
          if @previous("status") == "queued" and @status == "paused"
            throw new Error "Queued campaigns can not be paused."
 
    }
    hooks: {
      beforeCreate: (campaign)->
        campaign.quantity_needed = campaign.quantity_requested

      
      afterCreate: (campaign)->
        if campaign.status == "pending"
          LIBS.slack.message {
            text: "A new campaign has been created and is awaiting our approval! <#{CONFIG.web_server.host}/admin/pending_campaigns|Pending Campaigns>"
          }

      
      beforeUpdate: (campaign)->
        if campaign.changed("status")
          if campaign.previous("status") == "pending"
            campaign.start_at = campaign.start_at or new Date()
            campaign.email_status("campaign_#{ if campaign.status == "rejected" then "rejected" else "approved" }")
         
          if campaign.status == "completed" 
            campaign.start_at = campaign.start_at or new Date()
            campaign.end_at = campaign.end_at or new Date()
            campaign.email_status("campaign_completed")
      
            
      afterUpdate: (campaign)-> 
        campaign.getIndustries().each (industry)->
          if industry.status != "complete"              
            industry.status = campaign.status
            industry.save()
      
            
      afterDestroy: (campaign)->
        campaign.update({
          status: "completed"
        })

    }
  }