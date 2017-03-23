url = require 'url'
randomstring = require "randomstring"
numeral = require "numeral"
moment = require "moment"

module.exports = (sequelize, DataTypes)->

  return sequelize.define "Advertiser", {
    name: { 
      type: DataTypes.STRING
      allowNull: false
    }
    domain: { 
      type: DataTypes.STRING
      allowNull: false
      validate: {
        isUrl: {
          msg: "Must be valid domain name"
        }
      }
      set: (value)->
        value = @extract_domain value
        @setDataValue 'domain', value
    }
    key: { 
      type: DataTypes.STRING
      unique: true
      allowNull: false
    }
    is_demo: {
      type: DataTypes.BOOLEAN
      defaultValue: false
    }
    config: {
      type: DataTypes.JSONB
      defaultValue: {}
    }
    billed_spend: {
      type: DataTypes.VIRTUAL
      get: ->      
        total = 0
        
        if not @transfers?
          return NaN
        
        for transfer in @transfers
          if transfer.is_transferred
            total += transfer.amount
         
        return total
    }
    pending_spend: {
      type: DataTypes.VIRTUAL
      get: ->      
        total = 0
        
        if not @transfers?
          return NaN
        
        for transfer in @transfers
          if not transfer.is_transferred
            total += transfer.amount
         
        return total
    }
    upcoming_charges: {
      type: DataTypes.VIRTUAL
      get: ->      
        total = 0
        
        if not @campaigns?
          return NaN
        
        for campaign in @campaigns
          if campaign.status != "completed"
            total += campaign.spend
         
        return total
    }
    metrics: {
      type: DataTypes.VIRTUAL
      get: ->      
        return {
          billed_spend: numeral(@billed_spend).format("$0[,]000.00")
          pending_spend: numeral(@pending_spend).format("$0[,]000.00")
          upcoming_charges: numeral(@upcoming_charges).format("$0[,]000.00")
        }
    }
    auto_approve: {
      type: DataTypes.DECIMAL(3)
      defaultValue: 30
      get: ->      
        return Number @getDataValue("auto_approve")
        
    }
    auto_approve_at: {
      type: DataTypes.VIRTUAL
      get: ->
        return moment().subtract(@auto_approve, "days").toDate()
    }
  }, {    
    classMethods: {      
      associate: (models)->
        models.Advertiser.belongsToMany models.User, {
          as: 'members'
          through: "UserAdvertiser"
        }
        
        models.Advertiser.belongsTo models.User, { 
          as: 'admin_contact' 
        }
        
        models.Advertiser.belongsTo models.User, { 
          as: 'owner' 
        }
        
        models.Advertiser.hasMany models.Transfer, { 
          as: 'transfers' 
        }
        
        models.Advertiser.hasMany models.Campaign, { 
          as: 'campaigns' 
        }
        
        models.Advertiser.hasMany models.UserAccess, {
          as: 'invites'
        }

    }
    instanceMethods: {      
      extract_domain: (website)->
        domain = url.parse website.toLowerCase()
        hostname = (domain.hostname || domain.pathname).split(".").slice(-2).join(".")
        return "#{hostname}#{if domain.port? then (":" + domain.port) else "" }"    
        
      keen_generate: ->
        @config.keen = LIBS.keen.scopeKey {
          allowed_operations: ["read"],
          filters: [{
            property_name: "advertiser.id",
            operator: "eq",
            property_value: @id
          }, {
            property_name: "advertiser.key",
            operator: "eq",
            property_value: @key
          }]
        }
        
        @update {
          config: @config
        }
        
      
      approve_spending: (query_additional={})->
        advertiser = @
        query = {
          is_transferred: false
          type: "charge"
        }
        
        for key, value of query_additional
          query[key] = value
                
        Promise.props({
          owner: advertiser.owner or advertiser.getOwner()
          transfers: advertiser.getTransfers({
            where: query
          })
        }).then (props)->
          if not props.owner.stripe_card?
            return Promise.reject "Please enter in your billing details before approving any spend."
        
          Promise.each props.transfers, (transfer)->          
            LIBS.mixpanel.people.track_charge advertiser.owner_id, transfer.amount
            LIBS.stripe.charges.create({
              amount: transfer.stripe_amount
              customer: props.owner.stripe_id
              currency: "usd"
              description: transfer.name
              receipt_email: props.owner.email
              metadata: {
                user: transfer.user_id
                advertiser: transfer.advertiser_id
                campaign: transfer.campaign_id
              }
            }).then ->
              transfer.is_transferred = true
              transfer.transferred_at = new Date()
              transfer.stripe_card = props.owner.getDataValue("stripe_card")
              transfer.save()

        
      associations: (fetch)->
        fetch = fetch or { 
          owner: true
          admin_contact: true
        }
      
        Promise.resolve().then =>
          if not fetch["owner"] or @owner? then return
          
          @getOwner().then (owner)=>
            @owner = owner
            
        .then =>
          if not fetch["admin_contact"] or @admin_contact? then return
          
          @getAdmin_contact().then (admin)=>
            @admin_contact = admin
            
        .then => @
    
        
      intercom: (api=false)->          
        if not api 
          return Promise.resolve {
            id: @key
          }
            
        @associations().then =>            
          return {
            id: @key
            created_at: @created_at
            name: @name
            custom_attributes: {
              type: "advertiser"
              card: !!@owner.stripe_card
              auto_approve: @auto_approve
              admin: if @admin_contact? then @admin_contact.name else null
            }
          }
      
    }
    hooks: {
      beforeValidate: (advertiser)->
        if not advertiser.key?
          advertiser.key = randomstring.generate({
            length: Math.floor(Math.random() * 4) + 4
            charset: 'alphabetic'
          }).toLowerCase()
            
      
      beforeCreate: (advertiser)->
        advertiser.auto_approval = 30
        advertiser.config = {
          keen: null
        }
  
      
      afterCreate: (advertiser)->
        advertiser.keen_generate()

    }
  }