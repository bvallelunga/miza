crypto = require 'crypto'

module.exports = (sequelize, DataTypes)->
  hasher = (value)->
    return crypto.createHash('md5').update(value).digest('hex')

  return sequelize.define "User", {
    email: { 
      type: DataTypes.STRING,
      unique: true
      allowNull: false
      validate: {
        isEmail: {
          msg: "Must be valid a email address"
        }
      }
    }
    password: {
      type: DataTypes.STRING
      allowNull: false
      set: (value)->
        @setDataValue 'password', @hash(value) 
    }
    name: DataTypes.STRING 
    is_admin: { 
      type: DataTypes.BOOLEAN
      defaultValue: false
    } 
  }, {
    classMethods: {
      hash: hasher
      
      associate: (models)->
        models.User.belongsToMany models.Publisher, {
          as: 'publishers'
          through: "UserPublisher"
        }
    }
    instanceMethods: {
      hash: hasher
      
      validPassword: (password)->
        return bcrypt.compareSync password, @password
    }
  }