module.exports = ->
  return {
    models: require("./sequelize")()
    redis: require("./redis")()
  }