module.exports = { 

  up: (knex)->    
    knex.schema.table 'Event', (table)->
      table.dateTime("paid_at")
  
  
  down: (knex)->
    knex.schema.table 'Event', (table)->
      table.dropColumn("paid_at")

}