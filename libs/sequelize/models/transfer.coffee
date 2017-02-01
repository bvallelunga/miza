module.exports = (sequelize, DataTypes)->
  
  return sequelize.define "Transfer", {
    type: { 
      type: DataTypes.STRING
      allowNull: false
    }
    paypal: {
      type: DataTypes.STRING
      allowNull: false
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
        return Number @getDataValue("impression_count")
    }
    clicks: {
      type: DataTypes.DECIMAL(15)
      defaultValue: 0
      get: ->      
        return Number @getDataValue("click_count")
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
    }
  }