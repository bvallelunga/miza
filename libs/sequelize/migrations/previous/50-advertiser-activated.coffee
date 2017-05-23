module.exports = { 

  up: (knex)->   
    knex.schema.hasTable('Advertiser').then (exists)->
      if not exists then return     

      knex.schema.table 'Advertiser', (table)->
        table.boolean("is_activated").defaultTo(false)

    
  down: (knex)->   
    knex.schema.hasTable('Advertiser').then (exists)->
      if not exists then return     

      knex.schema.table 'Advertiser', (table)->
        table.dropColumn("is_activated")

}