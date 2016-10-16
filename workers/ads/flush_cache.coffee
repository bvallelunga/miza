module.exports = require("../template") (job)->
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

