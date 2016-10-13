module.exports = { 

  up: (knex, models)->  
    models.Publisher.findAll().then (publishers)->
      Promise.map publishers, (publisher)->
        new Promise (res, rej)->
          to = "publisher.#{publisher.key}.events"
          from = "#{publisher.key}.events"
          
          LIBS.redis.get from, (error, response)->
            if error?
              return rej error
            
            if not response?
              return res()
            
            LIBS.redis.set to, response, (error, response)->
              if error?
                return rej error
              
              res()


  down: (knex, models)->
    models.Publisher.findAll().then (publishers)->
      Promise.map publishers, (publisher)->
        new Promise (res, rej)->
          to = "#{publisher.key}.events"
          from = "publisher.#{publisher.key}.events"
          
          LIBS.redis.get from, (error, response)->
            if error?
              return rej error
            
            if not response?
              return res()
              
            LIBS.redis.set to, response, (error, response)->
              if error?
                return rej error
              
              res()

}