module.exports = (job, done)-> 
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
      
  .then(-> done()).catch (error)->
    if CONFIG.is_prod
      LIBS.bugsnag.notify error
    else
      console.error error
      
    done error
