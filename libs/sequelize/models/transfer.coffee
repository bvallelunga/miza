module.exports = (sequelize, DataTypes)->
  
  return sequelize.define "Transfer", {
    type: { 
      type: DataTypes.STRING
      allowNull: false
    }
    paypal: {
      type: DataTypes.STRING
    }
    amount: {
      type: DataTypes.DECIMAL(15)
      defaultValue: 0
      get: ->      
        return Number @getDataValue("amount")
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
    note: DataTypes.STRING
    transferred_at: DataTypes.DATE
    is_transferred: { 
      type: DataTypes.BOOLEAN
      defaultValue: false
    } 
  }, {    
    classMethods: {      
      associate: (models)->
        models.Transfer.belongsTo models.Publisher, { 
          as: 'publisher' 
        }
        
        models.Transfer.belongsTo models.User, { 
          as: 'user' 
        }
        
        models.Transfer.belongsTo models.Payout, { 
          as: 'payout' 
        }
    }
  }