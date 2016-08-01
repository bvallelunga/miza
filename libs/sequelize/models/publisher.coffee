module.exports = (sequelize, DataTypes)->

  return sequelize.define "Publisher", {
    name: { 
      type: DataTypes.STRING,
      allowNull: false
    }
    domain: { 
      type: DataTypes.STRING,
      unique: true
      allowNull: false
      validate: {
        isUrl: {
          msg: "Must be valid domain name"
        }
      }
    }
    key: { 
      type: DataTypes.STRING,
      unique: true
      allowNull: false
    }
  }, {
    paranoid: true,
    underscored: true
    
    classMethods: {
      associate: (models)->
        models.Publisher.belongsToMany models.User, {
          as: 'Members'
          through: "UserPublisher"
        }
    }
    hooks: {
      beforeValidate: (publisher, options)->
        if not publisher.key?
          publisher.key = Math.random().toString(36).substr(2, 10)
          
      afterCreate: (publisher)->
        console.log 1, arguments

        
      afterUpdate: (publisher)->
        console.log 2, arguments

    }
  }