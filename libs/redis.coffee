RedisPromise = require('then-redis')
Redis = require('redis')

# Exports
module.exports = ->    
  redis = RedisPromise.createClient CONFIG.redis_url
  redis.redis = Redis.createClient CONFIG.redis_url
  return redis