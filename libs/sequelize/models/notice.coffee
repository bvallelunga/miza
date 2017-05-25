numeral = require "numeral"

module.exports = (sequelize, DataTypes)->
  
  return sequelize.define "Notice", {
    target: { 
      type: DataTypes.STRING
      allowNull: false
    }
    message: { 
      type: DataTypes.STRING
      allowNull: false
    }
    start_at: { 
      type: DataTypes.DATE
      allowNull: false
    }
    end_at: { 
      type: DataTypes.DATE
      allowNull: false
    }
  }, {    
    classMethods: {      
      associate: (models)->
        models.Notice.belongsTo models.User, { 
          as: 'owner' 
        }

    }
  }