module.exports = ->
  return {
    models: require("./sequelize")()
    redis: require("./redis")()
    heroku: require("./heroku")()
  }