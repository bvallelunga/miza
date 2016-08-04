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
      
        this.setDataValue 'ip_address', value
    }
    asset_url: {
      type: DataTypes.TEXT
      validate: {
        isUrl: true
      }
    }
    protected: { 
      type: DataTypes.BOOLEAN
      allowNull: false
    }
  }