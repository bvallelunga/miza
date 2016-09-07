module.exports = (sequelize, DataTypes)->
  
  return sequelize.define "PublisherReport", {
    fee: {
      defaultValue: 0
      allowNull: false
      type: DataTypes.DECIMAL(4,3)
      get: ->      
        return Number @getDataValue("fee")
    }
    cpm: {
      defaultValue: 0
      allowNull: false
      type: DataTypes.DECIMAL(6,3)
      get: ->      
        return Number @getDataValue("cpm")
    }  
    cpc: {
      defaultValue: 0
      allowNull: false
      type: DataTypes.DECIMAL(6,3)
      get: ->      
        return Number @getDataValue("cpc")
    }
    ctr: {
      defaultValue: 0
      allowNull: false
      type: DataTypes.DECIMAL(4,3)
      get: ->      
        return Number @getDataValue("ctr")
    }
    revenue: {
      defaultValue: 0
      allowNull: false
      type: DataTypes.DECIMAL(13,2)
      get: ->      
        return Number @getDataValue("revenue")
    }
    protected: {
      defaultValue: 0
      allowNull: false
      type: DataTypes.DECIMAL(4,3)
      get: ->      
        return Number @getDataValue("protected")
    }
    owed: {
      defaultValue: 0
      allowNull: false
      type: DataTypes.DECIMAL(13,2)
      get: ->      
        return Number @getDataValue("owed")
    }
    pings_all: {
      defaultValue: 0
      allowNull: false
      type: DataTypes.DECIMAL(13)
      get: ->      
        return Number @getDataValue("pings_all")
    }
    pings: {
      defaultValue: 0
      allowNull: false
      type: DataTypes.DECIMAL(13)
      get: ->      
        return Number @getDataValue("pings")
    }
    impressions: {
      defaultValue: 0
      allowNull: false
      type: DataTypes.DECIMAL(13)
      get: ->      
        return Number @getDataValue("impressions")
    }
    clicks: {
      defaultValue: 0
      allowNull: false
      type: DataTypes.DECIMAL(13)
      get: ->      
        return Number @getDataValue("clicks")
    }
    paid_at: DataTypes.DATE
  }, {
    classMethods: {      
      associate: (models)->
        models.PublisherReport.belongsTo models.Publisher, { 
          as: 'publisher' 
        }
    
    }
  }
