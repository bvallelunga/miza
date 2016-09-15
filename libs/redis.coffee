Redis = require("redis")

# Exports
module.exports = ->
  return Redis.createClient CONFIG.redis_url