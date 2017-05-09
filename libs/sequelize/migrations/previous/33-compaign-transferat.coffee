module.exports = { 

  up: (knex)->   
    knex.schema.hasTable('Campaign').then (exists)->
      if not exists then return     

      knex.schema.table 'Campaign', (table)->
        table.dateTime("transferred_at")
  
  
  down: (knex)->
    knex.schema.hasTable('Campaign').then (exists)->
      if not exists then return

      knex.schema.table 'Campaign', (table)->
        table.dropColumn("transferred_at")

}