module.exports = (sequelize, DataTypes)->

  return sequelize.define "Event", {
    ad_id: DataTypes.STRING
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
  }, {
    paranoid: true
    underscored: true
  }