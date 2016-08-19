module.exports = (sequelize, DataTypes)->

  return sequelize.define "OptOut", {
    email: { 
      type: DataTypes.STRING,
      allowNull: false
      validate: {
        isEmail: {
          msg: "Must be valid a email address"
        }
      }
    }
    ip_address: { 
      type: DataTypes.STRING
      allowNull: false
      validate: {
        isIP: {
          msg: "Must be valid a ip address"
        }
      }
    }
  }