module.exports = { 

  up: (knex, models)->   
    knex.schema.hasTable('Campaign').then (exists)->
      if not exists then return     
      
      knex.schema.table 'Campaign', (table)->
        table.decimal("quantity_daily_requested", 15, 0)
        table.decimal("quantity_daily_needed", 15, 0)


  down: (knex)->
    knex.schema.hasTable('Campaign').then (exists)->
      if not exists then return

      knex.schema.table 'Campaign', (table)->
        table.dropColumn("quantity_daily_requested")
        table.dropColumn("quantity_daily_needed")

}