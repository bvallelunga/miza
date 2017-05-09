module.exports = { 

  up: (knex, models)->   
    knex.schema.hasTable('Industry').then (exists)->
      if not exists then return     
      
      Promise.resolve().then ->
        knex.schema.table 'Industry', (table)->
          table.float("cpc", 6, 3).defaultTo(0)
      
      .then ->
        knex.schema.table 'IndustryAudit', (table)->
          table.float("cpc", 6, 3).defaultTo(0)


  down: (knex)->
    knex.schema.hasTable('Industry').then (exists)->
      if not exists then return
      
      Promise.resolve().then ->
        knex.schema.table 'Industry', (table)->
          table.dropColumn("cpc")
      
      .then -> 
        knex.schema.table 'IndustryAudit', (table)->
          table.dropColumn("cpc")

}