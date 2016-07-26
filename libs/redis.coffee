Redis = require("redis")
redis = Redis.createClient(process.env.REDIS_URL)

# Exports
module.exports = redis