module.exports = (sequelize, DataTypes)->

  return sequelize.define "Creative", {
    title: { 
      type: DataTypes.STRING
      allowNull: false
    }
    description: { 
      type: DataTypes.STRING
      allowNull: false
    }
    image: { 
      type: DataTypes.BLOB("long")
      allowNull: false
    }
    config: {
      type: DataTypes.JSONB
      defaultValue: {}
    }
  }, {    
    classMethods: {      
      associate: (models)->        
        models.Creative.belongsTo models.Advertiser, { 
          as: 'advertiser' 
        }

    }
  }