module.exports = { 

  up: (knex, models)->   
    knex.schema.hasTable('Event').then (exists)->
      if not exists then return     
      
      Promise.resolve().then ->
        knex.schema.table 'Event', (table)->
          table.string("product")
          
      .then ->
        models.Event.update {
          product: "protect"
        }, {
          where: {
            product: null
          }
        }

    
  down: (knex)->   
    knex.schema.hasTable('Event').then (exists)->
      if not exists then return     

      knex.schema.table 'Event', (table)->
        table.dropColumn("product")

}