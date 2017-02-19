module.exports = {
  sequelize: require("./sequelize")
  ads: require("./ads")
  redis: require("./redis")()
  heroku: require("./heroku")()
  stripe: require("./stripe")()
  mixpanel: require("./mixpanel")()
  sendgrid: require("./sendgrid")()
  agenda: require("./agenda")()
  bugsnag: require("./bugsnag")()
  github: require("./github")()
  cloudflare: require("./cloudflare")()
  intercom: require("./intercom")()
  paypal: require("./paypal")()
  keen: require("./keen")()
  queue: require "./queue"
  slack: require "./slack"
  helpers: require "./helpers"
  emails: require "./emails"
  exchanges: require "./exchanges"
  init: ->
    @sequelize().then (models)=>
      @models = models
      return @
}