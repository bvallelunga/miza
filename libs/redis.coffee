RedisPromise = require('then-redis')
Redis = require('redis')

# Exports
module.exports = ->
  createClient = (url)->
    if not url? 
      return null
    
    redis = RedisPromise.createClient url
    redis.redis = Redis.createClient url
    return redis 

  return {
    site: createClient CONFIG.redis.site 
    ads: createClient CONFIG.redis.ads 
  }