url = require 'url'
randomstring = require "randomstring"
moment = require "moment"
numeral = require "numeral"

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
      defaultValue: 1
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
        
        models.Publisher.hasMany models.UserAccess, {
          as: 'invites'
        }
        
        models.Publisher.belongsTo models.User, { 
          as: 'owner' 
        }
        
        models.Publisher.belongsToMany models.Network, {
          as: 'networks'
          through: "NetworkPublisher"
        }
        
        models.Publisher.hasMany models.Event, { 
          as: 'events' 
        }
        
        models.Publisher.hasMany models.Transfer, { 
          as: 'transfers' 
        }
        
        models.Publisher.belongsTo models.Industry, { 
          as: 'industry' 
        }

    }
    instanceMethods: {
      full_name: ->
        return "#{@name} (#{@product[0].toUpperCase()})"
      
      
      extract_domain: (website)->
        domain = url.parse website.toLowerCase()
        hostname = (domain.hostname || domain.pathname).split(".").slice(-2).join(".")
        return "#{hostname}#{if domain.port? then (":" + domain.port) else "" }"
      
      
      create_endpoint: ->
        if @miza_endpoint
          return "#{@key}.#{CONFIG.ads_server.domain}"
         
        return "#{@key}.#{@domain}"
      
      
      reports: (query, full_query={})->
        query.publisher_id = @id
        full_query.where = query
        full_query.order = [
          ['created_at', 'DESC']
        ]
                
        LIBS.models.PublisherReport.findAll(full_query).then (reports)->  
          Promise.map reports, (report)->
            return LIBS.models.PublisherReport.merge [report]
           
        .then (reports)->        
          Promise.props {
            all: reports
            totals: LIBS.models.PublisherReport.merge reports
          }
            
       
      pending_events: ->
        Promise.props({
          publisher_id: @id
          events: LIBS.models.Event.findAll({
            attributes: [ "id" ]
            where: {
              publisher_id: @id
              reported_at: null
            }
          })
          impressions: LIBS.models.Event.count({
            where: {
              publisher_id: @id
              protected: true
              type: "impression"
              reported_at: null
            }
          })
          clicks: LIBS.models.Event.count({
            where: {
              publisher_id: @id
              protected: true
              type: "click"
              reported_at: null
            }
          })
          pings: LIBS.models.Event.count({
            where: {
              publisher_id: @id
              protected: true
              type: "ping"
              reported_at: null
            }
          })
          pings_all: LIBS.models.Event.count({
            where: {
              publisher_id: @id
              type: "ping"
              reported_at: null
            }
          })
        })  
    
        
      cloudflare_add: (endpoint)->
        if CONFIG.disable.cloudflare
          return Promise.resolve()
        
        LIBS.cloudflare.browseZones({
          name: CONFIG.ads_server.protected_domain
        }).then (zones)->        
          record = LIBS.cloudflare.Cloudflare.DNSRecord.create {
            type: "CNAME"
            name: endpoint
            content: CONFIG.ads_server.protected_domain
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
          text: "#{@name} publisher is now activate! <#{CONFIG.web_server.host}/publisher/#{@key}/analytics|Publisher Analytics>"
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
          @reports({
            paid_at: null
            interval: "day"
            created_at: {
              $gte: moment().startOf("month").toDate()
              $lte: moment().endOf("month").toDate()
            }
          }).then (reports)=>             
            return {
              id: @key
              monthly_spend: reports.totals.owed
              created_at: @created_at
              name: @name
              custom_attributes: {
                industry: if @industry? then  @industry.name else null
                fee: @fee * 100
                coverage: @config.coverage * 100
                activated: @is_activated
                card: !!@owner.stripe_card
                paypal: @owner.paypal
                product: @product
                admin: if @admin_contact? then @admin_contact.name else null
                total_page_views: numeral(reports.totals.pings_all).format("0[,]000")
                miza_protection: numeral(reports.totals.protected).format("0[.]0%")
                protected_clicks: numeral(reports.totals.clicks).format("0[,]000")
                protected_impressions: numeral(reports.totals.impressions).format("0[,]000")
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
          refresh: {
            enabled: true
            interval: 40
          }
        }

      
      afterCreate: (publisher)->
        publisher.keen_generate()
      
        if publisher.miza_endpoint
          publisher.cloudflare_add publisher.endpoint
        
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
            publisher.cloudflare_add publisher.endpoint
            
          else
            publisher.cloudflare_remove publisher.key

    }
  }