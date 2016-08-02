Heroku = require('heroku-client')

# Exports
module.exports = ->
  console.log CONFIG.env
  return new Heroku { token: CONFIG.heroku_token }