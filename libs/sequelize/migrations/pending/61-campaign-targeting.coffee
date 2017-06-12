module.exports = { 

  up: (knex)->   
    knex.schema.hasTable('Campaign').then (exists)->
      if not exists then return     

      knex.schema.table 'Campaign', (table)->
        table.jsonb("targeting")


  down: (knex)->
    knex.schema.hasTable('Campaign').then (exists)->
      if not exists then return

      knex.schema.table 'Campaign', (table)->
        table.dropColumn("targeting")

}