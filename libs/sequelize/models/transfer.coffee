numeral = require "numeral"

module.exports = (sequelize, DataTypes)->
  
  return sequelize.define "Transfer", {
    name: { 
      type: DataTypes.STRING
      allowNull: false
    }
    type: { 
      type: DataTypes.STRING
      allowNull: false
    }
    stripe_card: {
      type: DataTypes.JSONB
      get: ->
        card = @getDataValue "stripe_card"
        if not card? then return null
        
        return "#{card.brand} #{card.last4}"
    }
    paypal: {
      type: DataTypes.STRING
    }
    amount: {
      type: DataTypes.DECIMAL(15)
      defaultValue: 0
      get: ->
        scaler = 1
      
        if @type == "refund"
          scaler = -1
          
        return scaler * Number @getDataValue("amount")
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
    config: {
      type: DataTypes.JSONB
      defaultValue: {}
    }
    metrics: {
      type: DataTypes.VIRTUAL
      get: ->      
        return {
          amount: numeral(@amount).format("$0[,]000.00")
          impressions: numeral(@impressions).format("0[,]000")
          clicks: numeral(@clicks).format("0[,]000")
        }
    }
  }, {    
    classMethods: {      
      associate: (models)->
        models.Transfer.belongsTo models.Publisher, { 
          as: 'publisher' 
        }
        
        models.Transfer.belongsTo models.Advertiser, { 
          as: 'advertiser' 
        }
        
        models.Transfer.belongsTo models.User, { 
          as: 'user' 
        }
        
        models.Transfer.belongsTo models.Payout, { 
          as: 'payout' 
        }
        
        models.Transfer.belongsTo models.Campaign, { 
          as: 'campaign'
        }
    }
  }