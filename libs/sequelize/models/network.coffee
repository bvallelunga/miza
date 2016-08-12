module.exports = (sequelize, DataTypes)->

  return sequelize.define "Network", {
    name: { 
      type: DataTypes.STRING
      allowNull: false
    }
    slug: { 
      type: DataTypes.STRING
      allowNull: false
    }
    entry_js: { 
      type: DataTypes.TEXT
      defaultValue: ""
    }
    domains: { 
      type: DataTypes.ARRAY(DataTypes.TEXT)
      defaultValue: []
    }
    targets: { 
      type: DataTypes.TEXT
      defaultValue: ""
    }
    entry_raw_url: {
      type: DataTypes.TEXT
    }
    entry_url: {
      type: DataTypes.TEXT
    }
    is_enabled: { 
      type: DataTypes.BOOLEAN
      defaultValue: false
    } 
  }, {    
    classMethods: {      
      associate: (models)->
        models.Network.belongsToMany models.Publisher, {
          as: 'publishers'
          through: "NetworkPublisher"
        }
        
        models.Network.hasMany(models.Event, { 
          as: 'events' 
        })

    }
    hooks: {
      beforeValidate: (network, options)->
        network.entry_url = new Buffer(network.entry_raw_url).toString('base64')
        network.targets = network.domains.map (domain)->
          return "(#{domain})"
        .join "|"
          
    }
  }