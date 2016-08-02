Heroku = require('heroku-client')

# Exports
module.exports = ->
  console.log CONFIG.heroku_token
  return new Heroku { token: CONFIG.heroku_token }