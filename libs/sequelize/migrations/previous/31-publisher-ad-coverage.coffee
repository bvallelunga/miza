module.exports = { 

  up: (knex, models)->   
    knex.schema.hasTable('Publisher').then (exists)->
      if not exists then return     
      
      models.Publisher.findAll().each (publisher)->
        publisher.config.ad_coverage = 0.333
        publisher.update({
          config: publisher.config
        })

}