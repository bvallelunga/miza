module.exports = (sequelize, DataTypes)->

  return sequelize.define "UserAccess", {
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
  }, {
    paranoid: true,
    underscored: true

    hooks: {
      beforeValidate: (publisher, options)->
        if not publisher.key?
          publisher.key = Math.random().toString(36).substr(2, 10)
    }
  }