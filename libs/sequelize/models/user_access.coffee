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
    is_admin: { 
      type: DataTypes.BOOLEAN
      defaultValue: false
    } 
  }