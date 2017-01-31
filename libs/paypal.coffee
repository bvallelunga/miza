paypal = require "paypal-rest-sdk"

# Exports
module.exports = ->
  paypal.configure CONFIG.paypal
  return paypal