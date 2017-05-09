module.exports = { 

  up: (knex)->   
    knex.schema.hasTable('Publisher').then (exists)->
      if not exists then return     

      knex.schema.table 'Publisher', (table)->
        table.jsonb("abtest").defaultTo(JSON.stringify {
          coverage: 1
        })


  down: (knex)->
    knex.schema.hasTable('Publisher').then (exists)->
      if not exists then return

      knex.schema.table 'Publisher', (table)->
        table.dropColumn("abtest")

}