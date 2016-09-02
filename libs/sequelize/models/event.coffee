module.exports = (sequelize, DataTypes)->

  return sequelize.define "Event", {
    network_name: DataTypes.STRING
    type: { 
      type: DataTypes.ENUM("impression", "click", "asset", "ping")
      allowNull: false
    }
    ip_address: { 
      type: DataTypes.STRING
      allowNull: false
      validate: {
        isIP: true
      }
      set: (value)->      
        if value == "::1" or value == "::ffff:127.0.0.1" 
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
    browser: {
      type: DataTypes.JSONB
      defaultValue: {}
    }
    device: {
      type: DataTypes.JSONB
      defaultValue: {}
    }
    paid_at: DataTypes.DATE
  }, {
    classMethods: {
      queue: (req, data)->                               
        LIBS.queue.publish "event-queued", {
          type: data.type 
          ip_address: req.ip or req.ips
          protected: req.query.protected == "true"
          asset_url: data.asset_url
          publisher_id: data.publisher.id
          network_id: if data.network then data.network.id else null
          network_name: if data.network then data.network.name else null
          referrer_url: req.get('referrer')
          cookies: req.cookies
          headers: req.headers
          browser: {
            demensions: req.query.demensions or {}
            plugins: req.query.plugins or []
            languages: req.query.languages or []
            do_not_track: req.query.do_not_track == "true"
          }
          device: {
            components: req.query.components or []
            battery: req.query.battery or {}
          }
        }
    }
  }