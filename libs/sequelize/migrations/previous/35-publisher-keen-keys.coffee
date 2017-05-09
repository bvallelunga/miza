module.exports = { 

  up: (knex, models)->   
    knex.schema.hasTable('Publisher').then (exists)->
      if not exists then return     
      
      models.Publisher.findAll().each (publisher)->
        publisher.keen_generate()

}