request = require "request-promise"

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
        return (@get("description") or "")
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
        isIn: {
          args: [['300 x 250', "social", "twitter", "soundcloud", "product", "crowdsource"]]
          msg: "Invalid creative format"
        }
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
        request({
          method: "GET"
          encoding: null
          url: url
        })
      
      demo_frame: ->
        host = CONFIG.web_server.domain.split(".").slice(-2).join(".")
        link = "//#{LIBS.models.defaults.demo_publisher.key}.#{host}/demo?"
        params = [
          "width=300"
          "height=300"
        ].join("&")
        
        return link + params
        
      example_frame: (override, width=300, height=300)->
        host = CONFIG.web_server.domain.split(".").slice(-2).join(".")
        link = "//#{LIBS.models.defaults.demo_publisher.key}.#{host}/example?"
        params = [
          "width=#{width}"
          "height=#{height}"
          "creative_override=example_#{override}"
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
      
      
      video_link: (publisher, industry, is_protected, is_demo)->    
        return "v?" + [
          "creative=#{@id}",
          "advertiser=#{@advertiser_id}"
          "campaign=#{@campaign_id}"
          "industry=#{industry}"
          "protected=#{is_protected}"
          "video=#{@config.video}"
        ].join("&")
      
      
      attributed_link: (publisher, industry, is_protected, is_demo, link=@link)->          
        link += if link.indexOf("?") == -1 then "?" else "&"
      
        original_url = "#{link}utm_publisher=#{publisher}"
        link = "#{ @protected_url(link) }?"
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
     
     
      protected_url: (link)->
        return new Buffer(link).toString("base64")
    }
  }