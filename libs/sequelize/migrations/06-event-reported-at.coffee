module.exports = { 

  up: (knex)->   
    knex.schema.hasTable('Event').then (exists)->
      if not exists then return     

      knex.schema.table 'Event', (table)->
        table.dateTime("reported_at")
  
  
  down: (knex)->
    knex.schema.hasTable('Event').then (exists)->
      if not exists then return

      knex.schema.table 'Event', (table)->
        table.dropColumn("reported_at")

}