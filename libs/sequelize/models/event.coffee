module.exports = (sequelize, DataTypes)->

  return sequelize.define "Event", {
    ad_id: DataTypes.STRING
    ad_network: DataTypes.STRING
    type: { 
      type: DataTypes.ENUM("impression", "click", "asset")
      allowNull: false
    }
    ip_address: { 
      type: DataTypes.STRING
      allowNull: false
      validate: {
        isIP: true
      }
      set: (value)->
        if value == "::1"
          value = "127.0.0.1"
      
        @setDataValue 'ip_address', value
    }
    asset_url: {
      type: DataTypes.TEXT
      validate: {
        isUrl: true
      }
    }
    referrer_url: {
      type: DataTypes.TEXT
      validate: {
        isUrl: true
      }
    }
    protected: { 
      type: DataTypes.BOOLEAN
      allowNull: false
    }
    cookies: {
      type: DataTypes.JSONB
      defaultValue: {}
    }
    headers: {
      type: DataTypes.JSONB
      defaultValue: {}
    }
    geo_location: {
      type: DataTypes.JSONB
      defaultValue: {}
    }
  }, {
    classMethods: {
      generate: (req, publisher, data)->        
        LIBS.models.Event.create({
          type: data.type 
          ip_address: req.ip or req.ips
          protected: req.query.blocker == "true"
          asset_url: data.asset_url
          publisher_id: publisher.id
          ad_network: data.ad_network
          referrer_url: req.get('Referrer')
          cookies: req.cookies
          headers: req.headers
        })
       
    }
    hooks: {
      afterCreate: (publisher)->
        LIBS.queue.publish "event-created", publisher
    }
  }