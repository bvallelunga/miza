module.exports = { 

  up: (knex)->   
    knex.schema.hasTable('Publisher').then (exists)->
      if not exists then return     

      knex.schema.table 'Publisher', (table)->
        table.float("fee", 4, 3).defaultTo(0)


  down: (knex)->
    knex.schema.hasTable('Publisher').then (exists)->
      if not exists then return

      knex.schema.table 'Publisher', (table)->
        table.dropColumn("fee")

}