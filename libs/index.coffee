module.exports = ->
  return {
    sequelize: require("./sequelize")()
    redis: require("./redis")()
  }