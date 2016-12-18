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
        
        models.Network.hasMany models.Event, { 
          as: 'events' 
        }

    }
  }