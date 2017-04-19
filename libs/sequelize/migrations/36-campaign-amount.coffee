module.exports = { 

  up: (knex, models)->   
    knex.schema.hasTable('Campaign').then (exists)->
      if not exists then return     
      
      knex.schema.table 'Campaign', (table)->
        table.float("amount", 6, 3).defaultTo(0)


  down: (knex)->
    knex.schema.hasTable('Campaign').then (exists)->
      if not exists then return
      
      knex.schema.table 'Campaign', (table)->
        table.dropColumn("amount")
      
}