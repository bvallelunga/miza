module.exports = ->
  return {
    models: require("./sequelize")()
    redis: require("./redis")()
    heroku: require("./heroku")()
    stripe: require("./stripe")()
    mixpanel: require("./mixpanel")()
    mailgun: require("./mailgun")()
    queue: require "./queue"
    slack: require "./slack"
    helpers: require "./helpers"
  }