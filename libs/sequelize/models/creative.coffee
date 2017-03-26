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
        isIn: [['300 x 250']]
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
    }
    
    instanceMethods: {
      attributed_link: (industry, is_protected)->
        link = "#{ new Buffer(@link).toString("base64") }?"
        params = [
          "creative=#{@id}",
          "advertiser=#{@advertiser_id}"
          "campaign=#{@campaign_id}"
          "industry=#{industry}"
          "protected=#{is_protected}"
        ].join("&")
        
        return link + params
        
    }
  }