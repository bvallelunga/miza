module.exports = { 

  up: (knex, models)->  
    knex.schema.hasTable('Publisher').then (exists)->
      if not exists then return   
    
      models.Publisher.findAll().each (publisher)->
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
    return true

}