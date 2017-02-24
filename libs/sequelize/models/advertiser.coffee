url = require 'url'
randomstring = require "randomstring"
moment = require "moment"
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
      beforeValidate: (publisher)->
        if not publisher.key?
          publisher.key = randomstring.generate({
            length: Math.floor(Math.random() * 4) + 4
            charset: 'alphabetic'
          }).toLowerCase()
          publisher.endpoint = publisher.create_endpoint()
            
      
      beforeCreate: (publisher)->
        publisher.config = {
          keen: null
        }

      
      afterCreate: (publisher)->
        publisher.keen_generate()

    }
  }