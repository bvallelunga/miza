url = require 'url'
randomstring = require "randomstring"

module.exports = (sequelize, DataTypes)->

  return sequelize.define "Publisher", {
    name: { 
      type: DataTypes.STRING,
      allowNull: false
    }
    domain: { 
      type: DataTypes.STRING,
      unique: true
      allowNull: false
      validate: {
        isUrl: {
          msg: "Must be valid domain name"
        }
      }
      set: (value)->
        value = @extract_domain value
        @setDataValue 'domain', value 
        @setDataValue 'endpoint', "#{@key}.#{value.split(".").slice(-2).join(".")}"
    }
    endpoint: {
      type: DataTypes.STRING,
      unique: true
      allowNull: false
      validate: {
        isUrl: {
          msg: "Must be valid endpoint name"
        }
      }
    }
    key: { 
      type: DataTypes.STRING,
      unique: true
      allowNull: false
    }
    is_demo: {
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
      
      
      merge_reports: (reports)->
        report_totals = LIBS.models.PublisherReport.build()
        reports_length = 0
        
        Promise.each reports, (report)->
          report_totals.fee += report.fee
          report_totals.cpm += report.cpm
          report_totals.cpc += report.cpc
          report_totals.protected += report.protected
          report_totals.revenue += report.revenue
          report_totals.owed += report.owed
          report_totals.pings_all += report.pings_all
          report_totals.pings += report.pings
          report_totals.impressions += report.impressions
          report_totals.clicks += report.clicks
          reports_length++
          
        .then ->
          reports_length = Math.max 1, reports_length
        
          report_totals.fee = report_totals.fee / reports_length
          report_totals.cpm = report_totals.cpm / reports_length
          report_totals.cpc = report_totals.cpc / reports_length
          report_totals.ctr = report_totals.clicks / (report_totals.impressions or 1)
          report_totals.protected = report_totals.pings / (report_totals.pings_all or 1)
          
          return report_totals

    }
    instanceMethods: {
      extract_domain: (website)->
        domain = url.parse website.toLowerCase()
        hostname = (domain.hostname || domain.pathname).split(".").slice(-2).join(".")
        return "#{hostname}#{if domain.port? then (":" + domain.port) else "" }"
      
      
      heroku_add_domain: (domain)->
        LIBS.heroku.post "/apps/#{CONFIG.app_name}/domains", {
          body: { hostname: domain }
        } 
       
       
      heroku_remove_domain: (domain)->
        LIBS.heroku.delete "/apps/#{CONFIG.app_name}/domains/#{domain}"
      
      
      reports: (query)->
        query.publisher_id = @id
        
        LIBS.models.PublisherReport.findAll({
          where: query
        }).then LIBS.models.Publisher.merge_reports
            
       
      pending_events: ->
        Promise.props({
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
    }
    hooks: {
      beforeValidate: (publisher, options)->
        if not publisher.key?
          publisher.key = randomstring.generate({
            length: Math.floor(Math.random() * 4) + 4
            charset: 'alphabetic'
          }).toLowerCase()
          publisher.endpoint = "#{publisher.key}.#{publisher.domain}"
          
      
      afterCreate: (publisher, options, callback)->
        publisher.heroku_add_domain(publisher.endpoint).then ->
          callback()
        .catch console.warn

        
      afterUpdate: (publisher, options, callback)->
        if publisher.endpoint != publisher.previous("endpoint")
          publisher.heroku_add_domain(publisher.endpoint).then ->
            callback()
          .catch console.warn
          
        callback()

    }
  }