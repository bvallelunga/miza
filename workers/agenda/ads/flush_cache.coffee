module.exports = require("../template") {
  intervals: [
    ["ads.flush_cache", "0 0 * * *"]
  ]
  config: {
    priority: "low" 
  }
}, (job)->
  new Promise (res, rej)->  
    LIBS.redis.keys "ads_server.cache.*", (error, keys)->
      if error?
        return rej error
      
      if keys.length == 0
        return res()
      
      LIBS.redis.del keys, (error, count)->
        if error?
          return rej error
        
        console.log count
        res()

