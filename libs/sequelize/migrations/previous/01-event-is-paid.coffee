module.exports = { 

  up: (knex)->   
    knex.schema.hasTable('Event').then (exists)->
      if not exists then return     

      knex.schema.table 'Event', (table)->
        table.dateTime("paid_at")
  
  
  down: (knex)->
    knex.schema.hasTable('Event').then (exists)->
      if not exists then return

      knex.schema.table 'Event', (table)->
        table.dropColumn("paid_at")

}