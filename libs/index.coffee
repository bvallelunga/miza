module.exports = {
  sequelize: require("./sequelize")
  redis: require("./redis")()
  heroku: require("./heroku")()
  stripe: require("./stripe")()
  mixpanel: require("./mixpanel")()
  sendgrid: require("./sendgrid")()
  agenda: require("./agenda")()
  queue: require "./queue"
  slack: require "./slack"
  helpers: require "./helpers"
  init: ->
    @sequelize().then (models)=>
      @models = models
      return @
}