Redis = require("redis")
redis = null

# Exports
module.exports = ->
  return redis = redis or Redis.createClient(CONFIG.redis_url)