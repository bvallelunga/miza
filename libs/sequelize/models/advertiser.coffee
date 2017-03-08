url = require 'url'
randomstring = require "randomstring"
numeral = require "numeral"

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
        advertiser.config = {
          keen: null
        }
  
      
      afterCreate: (advertiser)->
        advertiser.keen_generate()

    }
  }