module.exports = { 

  up: (knex, models)->   
    knex.schema.hasTable('Publisher').then (exists)->
      if not exists then return     
      
      Promise.resolve().then ->
        knex.schema.table 'Publisher', (table)->
          table.jsonb("config").defaultTo("{}")
      
      .then ->
        models.Publisher.findAll().each (publisher)->
          publisher.update({
            config: {
              coverage: publisher.coverage_ratio
              abtest: publisher.abtest
              refresh: {
                enabled: true
                interval: 60
              }
            }
          })
          

  down: (knex)->
    knex.schema.hasTable('Publisher').then (exists)->
      if not exists then return

      knex.schema.table 'Publisher', (table)->
        table.dropColumn("abtest")

}