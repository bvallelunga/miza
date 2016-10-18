module.exports = { 

  up: (knex)->   
    knex.schema.hasTable('Publisher').then (exists)->
      if not exists then return     

      knex.schema.table 'Publisher', (table)->
        table.boolean("miza_endpoint").defaultTo(false)

    
  down: (knex)->   
    knex.schema.hasTable('Publisher').then (exists)->
      if not exists then return     

      knex.schema.table 'Publisher', (table)->
        table.dropColumn("miza_endpoint")

}