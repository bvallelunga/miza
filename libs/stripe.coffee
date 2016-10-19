Stripe = require "stripe"

# Exports
module.exports = ->
  return Stripe CONFIG.stripe.private