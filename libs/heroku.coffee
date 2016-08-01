Heroku = require('heroku-client')

# Exports
module.exports = ->
  return new Heroku({ token: CONFIG.heroku_token })