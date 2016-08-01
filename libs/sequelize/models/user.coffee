bcrypt = require "bcrypt-nodejs"

module.exports = (sequelize, DataTypes)->


  return sequelize.define "User", {
    email: { 
      type: DataTypes.STRING,
      unique: true
      allowNull: false
      validate: {
        isEmail: {
          msg: "Must be valid email address"
        }
      }
    }
    password: {
      type: DataTypes.STRING
      allowNull: false
      set: (value)->
        this.setDataValue 'password', this.generateHash(value) 
    }
    name: DataTypes.STRING 
    is_admin: { 
      type: DataTypes.BOOLEAN
      defaultValue: false
    } 
  }, {
    paranoid: true,
    underscored: true
    
    classMethods: {
      associate: (models)->
        models.User.belongsToMany models.Publisher, {
          as: 'Publishers'
          through: "UserPublisher"
        }
    }
    instanceMethods: {
      generateHash: (password)->
        return bcrypt.hashSync password, bcrypt.genSaltSync(8), null
      
      validPassword: (password)->
        return bcrypt.compareSync password, this.password
    }
  }