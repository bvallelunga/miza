module.exports = (sequelize, DataTypes)->

  return sequelize.define "Campaign", {
    name: { 
      type: DataTypes.STRING
      allowNull: false
    }
    type: {
      type: DataTypes.STRING
      allowNull: false
      validate: {
        isIn: [['prepaid']]
      }
    }
    status: {
      type: DataTypes.STRING
      allowNull: false
      validate: {
        isIn: [['draft', 'running', 'paused', 'archived', 'complete']]
      }
    }
    start_date: DataTypes.DATE
    end_date: DataTypes.DATE
    paid: {
      type: DataTypes.DECIMAL(13,2)
      defaultValue: 0
      allowNull: false
      get: ->      
        return Number @getDataValue("paid")
    }
    impressions: {
      type: DataTypes.DECIMAL(15)
      defaultValue: 0
      get: ->      
        return Number @getDataValue("impressions")
    }
    clicks: {
      type: DataTypes.DECIMAL(15)
      defaultValue: 0
      get: ->      
        return Number @getDataValue("clicks")
    }
    refunded: {
      type: DataTypes.DECIMAL(13,2)
      defaultValue: 0
      allowNull: false
      get: ->      
        return Number @getDataValue("refunded")
    }
    config: {
      type: DataTypes.JSONB
      defaultValue: {}
    }
  }, {    
    classMethods: {      
      associate: (models)->        
        models.Campaign.belongsTo models.Advertiser, { 
          as: 'advertiser' 
        }

    }
  }