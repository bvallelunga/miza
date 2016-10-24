url = require 'url'
randomstring = require "randomstring"
moment = require "moment"

module.exports = (sequelize, DataTypes)->

  return sequelize.define "Publisher", {
    name: { 
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
    coverage_ratio: {
      type: DataTypes.DECIMAL(3,2)
      defaultValue: 1
      validate: {
        min: {
          args: [ 0 ]
          msg: "Coverage must be greater than or equal to 0%"
        }
        max: {
          args: [ 1 ]
          msg: "Coverage must be less than or equal to 100%"
        }
      }
      get: ->      
        return Number @getDataValue("coverage_ratio")
   
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
        
        models.Publisher.belongsTo models.Industry, { 
          as: 'industry' 
        }

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
          text: "#{@name} publisher is now activate! <#{CONFIG.web_server.host}/dashboard/#{@key}/analytics|Publisher Analytics>"
        }
        
      intercom: (api=false)->
        Promise.resolve().then =>
          if @industry? then return @
          
          @getIndustry().then (industry)=>
            @industry = industry
            
        .then =>
          if @owner? then return @
          
          @getOwner().then (owner)=>
            @owner = owner
            
        .then =>
          @reports({
            paid_at: null
            interval: "day"
            created_at: {
              $gte: moment().startOf("month").toDate()
              $lte: moment().endOf("month").toDate()
            }
          }).then (reports)=> 
            attrs = {
              id: @id
              key: @key
              name: @name
              industry: @industry.name
              fee: @fee * 100
              coverage: @coverage_ratio * 100
              activated: @is_activated
              card: !!@owner.stripe_card
              monthly_spend: reports.totals.owed
              created_at: @created_at
            }
            
            if not api then return attrs
            
            return {
              id: @id
              monthly_spend: attrs.monthly_spend
              created_at: attrs.created_at
              custom_attributes: {
                key: attrs.key
                name: attrs.name
                industry: attrs.industry
                fee: attrs.fee
                coverage: attrs.coverage
                activated: attrs.activated
                card: attrs.card
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
          
          
      beforeUpdate: (publisher)->
        publisher.endpoint = publisher.create_endpoint()
          
      
      afterCreate: (publisher)->
        publisher.heroku_add(publisher.endpoint)
        
        if publisher.miza_endpoint
          publisher.cloudflare_add publisher.endpoint

        
      afterUpdate: (publisher)->
        if publisher.endpoint != publisher.previous("endpoint")
          publisher.heroku_add(publisher.endpoint)
          
        if publisher.is_activated and publisher.changed("is_activated")
          publisher.publisher_activated()
            
        if publisher.miza_endpoint != publisher.previous("miza_endpoint")
          if publisher.miza_endpoint
            publisher.cloudflare_add publisher.endpoint
            
          else
            publisher.cloudflare_remove publisher.key

    }
  }