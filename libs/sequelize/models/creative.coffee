request = require "request"

module.exports = (sequelize, DataTypes)->

  return sequelize.define "Creative", {
    link: { 
      type: DataTypes.STRING
      allowNull: false
    }
    description: DataTypes.STRING
    description_html: {
      type: DataTypes.VIRTUAL
      get: ->
        return @get("description")
          .replace(/&/g, '&amp;')
          .replace(/>/g, '&gt;')
          .replace(/</g, '&lt;')
          .replace(/\n/g, '<br>')
    }
    title: DataTypes.STRING
    format: {
      type: DataTypes.STRING
      allowNull: false
      validate: {
        isIn: [['300 x 250', "social"]]
      }          
    }
    image: { 
      type: DataTypes.BLOB("long")
      allowNull: false
    }
    trackers: {
      type: DataTypes.JSONB
      defaultValue: []
    }
    config: {
      type: DataTypes.JSONB
      defaultValue: {}
    }
  }, {    
    classMethods: {      
      associate: (models)->        
        models.Creative.belongsTo models.Advertiser, { 
          as: 'advertiser' 
        }
        
        models.Creative.belongsTo models.Campaign, { 
          as: 'campaign' 
        }
        
      
      fetch_image: (url)->
        new Promise (res, rej)->
          request {
            method: "GET"
            encoding: null
            url: url
          }, (error, response, body)=>
            if error?
              return rej error
          
            res response.body
      
      
      demo_frame: ->
        host = CONFIG.web_server.domain.split(".").slice(-2).join(".")
        link = "//#{LIBS.models.defaults.demo_publisher.key}.#{host}/demo?"
        params = [
          "width=300"
          "height=300"
        ].join("&")
        
        return link + params
    }
    
    instanceMethods: {
      demo_frame: ->
        host = CONFIG.web_server.domain.split(".").slice(-2).join(".")
        link = "//#{LIBS.models.defaults.demo_publisher.key}.#{host}/a?"
        params = [
          "demo=true"
          "creative_override=#{@id}",
          "width=300"
          "height=300"
        ].join("&")
        
        return link + params
      
      
      attributed_link: (publisher, industry, is_protected, is_demo)->          
        @link += if @link.indexOf("?") == -1 then "?" else "&"
      
        original_url = "#{@link}utm_publisher=#{publisher}"
        link = "#{ new Buffer(original_url).toString("base64") }?"
        params = [
          "link"
        ]
        
        if not is_demo
          params = params.concat [
            "creative=#{@id}",
            "advertiser=#{@advertiser_id}"
            "campaign=#{@campaign_id}"
            "industry=#{industry}"
            "protected=#{is_protected}"
          ]
        
        return link + params.join("&")
        
    }
  }