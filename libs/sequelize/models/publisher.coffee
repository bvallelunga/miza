url = require 'url'
randomstring = require "randomstring"

module.exports = (sequelize, DataTypes)->

  return sequelize.define "Publisher", {
    name: { 
      type: DataTypes.STRING
      allowNull: false
    }
    product: { 
      type: DataTypes.STRING
      allowNull: false
    }
    fee: {
      defaultValue: 0.75
      allowNull: false
      type: DataTypes.DECIMAL(4,3)
      get: ->      
        return Number @getDataValue("fee")
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
    endpoint: {
      type: DataTypes.STRING
      unique: true
      allowNull: false
      validate: {
        isUrl: {
          msg: "Must be valid endpoint name"
        }
      }
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
    is_activated: {
      type: DataTypes.BOOLEAN
      defaultValue: false
    }
    miza_endpoint: {
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
        models.Publisher.belongsToMany models.User, {
          as: 'members'
          through: "UserPublisher"
        }
        
        models.Publisher.belongsTo models.User, { 
          as: 'admin_contact' 
        }
        
        models.Publisher.belongsTo models.User, { 
          as: 'owner' 
        }
        
        models.Publisher.hasMany models.Transfer, { 
          as: 'transfers' 
        }
        
        models.Publisher.belongsTo models.Industry, { 
          as: 'industry' 
        }
        
        models.Publisher.hasMany models.UserAccess, {
          as: 'invites'
        }
        
      keen_datasets: ->
        Promise.resolve([
          {
            timezone: "UTC"
            dataset_name: "publisher-impression-chart"
            display_name: "Publisher Impression Chart"
            analysis_type: "count"
            event_collection : "ads.event.impression"
            timeframe: "this_1_months"
            interval: "every_2_hours"
            filters: [{
              operator: "ne"
              property_name: "billing.house"
              property_value: true
            }]
          }
          {
            timezone: "UTC"
            dataset_name: "publisher-click-chart"
            display_name: "Publisher Click Chart"
            analysis_type: "count"
            event_collection : "ads.event.click"
            timeframe: "this_1_months"
            interval: "every_2_hours"
            filters: [{
              operator: "ne"
              property_name: "billing.house"
              property_value: true
            }]
          }
          {
            timezone: "UTC"
            dataset_name: "publisher-impression-count"
            display_name: "Publisher Impression Count"
            analysis_type: "count"
            event_collection : "ads.event.impression"
            timeframe: "this_1_months"
            interval: "every_2_hours"
            filters: [{
              operator: "ne"
              property_name: "billing.house"
              property_value: true
            }]
          }
          {
            timezone: "UTC"
            dataset_name: "publisher-click-count"
            display_name: "Publisher Click Count"
            analysis_type: "count"
            event_collection : "ads.event.click"
            timeframe: "this_1_months"
            interval: "every_2_hours"
            filters: [{
              operator: "ne"
              property_name: "billing.house"
              property_value: true
            }]
          }
          {
            timezone: "UTC"
            dataset_name: "publisher-request-count"
            display_name: "Publisher Request Count"
            analysis_type: "count"
            event_collection : "ads.event.request"
            timeframe: "this_1_months"
            interval: "every_2_hours"
            filters: [{
              operator: "ne"
              property_name: "billing.house"
              property_value: true
            }]
          }
          {
            timezone: "UTC"
            dataset_name: "publisher-delivery-count"
            display_name: "Publisher Delivery Count"
            analysis_type: "count"
            event_collection : "ads.event.delivery"
            timeframe: "this_1_months"
            interval: "every_2_hours"
            filters: [{
              operator: "ne"
              property_name: "billing.house"
              property_value: true
            }]
          }
          {
            timezone: "UTC"
            dataset_name: "publisher-ping-count"
            display_name: "Publisher Ping Count"
            analysis_type: "count"
            event_collection : "ads.event.ping"
            timeframe: "this_1_months"
            interval: "every_2_hours"
            filters: [{
              operator: "ne"
              property_name: "billing.house"
              property_value: true
            }]
          }
          {
            timezone: "UTC"
            dataset_name: "publisher-ping-protected-count"
            display_name: "Publisher Ping Protected Count"
            analysis_type: "count"
            event_collection : "ads.event.ping"
            timeframe: "this_1_months"
            interval: "every_2_hours"
            filters: [{
              "operator": "eq"
              "property_name": "protected"
              "property_value": true
            }, {
              operator: "ne"
              property_name: "billing.house"
              property_value: true
            }]
          }
          {
            timezone: "UTC"
            dataset_name: "publisher-os-protected-count"
            display_name: "Publisher OS Protected Count"
            analysis_type: "count"
            event_collection : "ads.event.ping"
            timeframe: "this_1_months"
            interval: "every_6_hours"
            filters: [{
              "operator": "eq"
              "property_name": "protected"
              "property_value": true
            }, {
              operator: "ne"
              property_name: "billing.house"
              property_value: true
            }]
            group_by: [
              "user_agent.parsed.os.family"
            ]
          }
          {
            timezone: "UTC"
            dataset_name: "publisher-browser-protected-count"
            display_name: "Publisher Browser Protected Count"
            analysis_type: "count"
            event_collection : "ads.event.ping"
            timeframe: "this_1_months"
            interval: "every_6_hours"
            group_by: [
              "user_agent.parsed.browser.family"
            ]
            filters: [{
              "operator": "eq"
              "property_name": "protected"
              "property_value": true
            }, {
              operator: "ne"
              property_name: "billing.house"
              property_value: true
            }]
          }
        ]).each (query)->
          LIBS.keen.createDataset(query.dataset_name, {
            display_name: query.display_name
            query: query
            index_by: ["publisher.key"]
          })
        
    }
    instanceMethods: {      
      extract_domain: (website)->
        domain = url.parse website.toLowerCase()
        hostname = (domain.hostname || domain.pathname).split(".").slice(-2).join(".")
        return "#{hostname}#{if domain.port? then (":" + domain.port) else "" }"
      
      
      create_endpoint: ->
        if @miza_endpoint
          return "#{@key}.#{CONFIG.ads_server.domain}"
         
        return "#{@key}.#{@domain}"
      
      
      cloudflare_add: (endpoint)->
        if CONFIG.disable.cloudflare
          return Promise.resolve()
          
        key = endpoint.replace(".#{CONFIG.ads_server.protected_domain}", "")
        
        LIBS.cloudflare.browseZones({
          name: CONFIG.ads_server.protected_domain
        }).then (zones)->        
          record = LIBS.cloudflare.Cloudflare.DNSRecord.create {
            type: "CNAME"
            name: key
            content: CONFIG.ads_server.domain
            zone_id: zones.result[0].id
            proxied: true
          }
          
          LIBS.cloudflare.addDNS record
          
        .catch(console.error)

        
      cloudflare_remove: (key)->
        if CONFIG.disable.cloudflare
          return Promise.resolve()
        
        LIBS.cloudflare.browseZones({
          name: CONFIG.ads_server.protected_domain
        }).then (zones)->        
          LIBS.cloudflare.browseDNS(zones.result[0])
        
        .then (records)->
          for record in records.result
            if record.name.indexOf(key) > -1
              return LIBS.cloudflare.deleteDNS record
              
        .catch(console.error)
  
        
      heroku_add: (endpoint)->
        LIBS.heroku.add_domain(endpoint)
          .catch(console.error)
          
      
      heroku_remove: (endpoint)->
        LIBS.heroku.remove_domain(endpoint)
          .catch(console.error)
      
      
      publisher_activated: ->
        LIBS.slack.message {
          text: "#{@name} publisher is now activate! <#{CONFIG.web_server.host}/dashboard/supply/#{@key}/analytics|Publisher Analytics>"
        }
        
        
      keen_generate: ->
        @config.keen = LIBS.keen.scopeKey {
          allowed_operations: ["read"],
          filters: [{
            property_name: "publisher.id",
            operator: "eq",
            property_value: @id
          }, {
            property_name: "publisher.key",
            operator: "eq",
            property_value: @key
          }, {
            operator: "ne"
            property_name: "billing.house"
            property_value: true
          }]
        }
        
        @update {
          config: @config
        }

        
      associations: (fetch)->
        fetch = fetch or { 
          industry: true
          owner: true
          admin_contact: true
        }
      
        Promise.resolve().then =>
          if not fetch["industry"] or @industry? then return
            
          @getIndustry().then (industry)=>
            @industry = industry
            
        .then =>
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
              type: "publisher"
              industry: if @industry? then  @industry.name else null
              fee: @fee * 100
              coverage: @config.coverage * 100
              activated: @is_activated
              card: if @owner? then !!@owner.stripe_card else false
              paypal: if @owner? then @owner.paypal else null
              product: @product
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
          abtest: {
            coverage: 1
          }
          coverage: 1
          ad_coverage: 0.5
          refresh: {
            enabled: true
            interval: 60
          }
        }

      
      afterCreate: (publisher)->
        publisher.keen_generate().then ->
      
          if publisher.miza_endpoint
            publisher.cloudflare_add(publisher.endpoint)
          
          else
            publisher.heroku_add(publisher.endpoint)


      beforeUpdate: (publisher)->
        publisher.endpoint = publisher.create_endpoint()

        
      afterUpdate: (publisher)->
        if not publisher.miza_endpoint and publisher.changed("endpoint")
          publisher.heroku_add(publisher.endpoint)
          
        if not publisher.is_demo and publisher.is_activated and publisher.changed("is_activated")
          publisher.publisher_activated()
            
        if publisher.changed("miza_endpoint")
          if publisher.miza_endpoint
            publisher.cloudflare_add(publisher.endpoint)
            
          else
            publisher.cloudflare_remove(publisher.key)

    }
  }