module.exports = { 

  up: (knex)->   
    knex.schema.hasTable('Publisher').then (exists)->
      if not exists then return     

      knex.schema.table 'Publisher', (table)->
        table.boolean("is_activated").defaultTo(false)

    
  down: (knex)->   
    knex.schema.hasTable('Publisher').then (exists)->
      if not exists then return     

      knex.schema.table 'Publisher', (table)->
        table.dropColumn("is_activated")

}