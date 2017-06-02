module.exports = { 

  up: (knex, models)->   
    knex.schema.hasTable('Campaign').then (exists)->
      if not exists then return     
      
      Promise.resolve().then ->
        knex.schema.table 'Campaign', (table)->
          table.float("credits", 6, 3).defaultTo(0)
      
      .then ->
        knex.schema.table 'Advertiser', (table)->
          table.float("credits", 6, 3).defaultTo(0)


  down: (knex)->
    knex.schema.hasTable('Campaign').then (exists)->
      if not exists then return
      
      Promise.resolve().then ->
        knex.schema.table 'Campaign', (table)->
          table.dropColumn("credits")
      
      .then -> 
        knex.schema.table 'Advertiser', (table)->
          table.dropColumn("credits")

}