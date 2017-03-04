module.exports = { 

  up: (knex, models)->   
    knex.schema.hasTable('Industry').then (exists)->
      if not exists then return     
      
      knex.schema.table 'Industry', (table)->
        table.decimal("max_impressions", 13).defaultTo(0)


  down: (knex)->
    knex.schema.hasTable('Industry').then (exists)->
      if not exists then return

      knex.schema.table 'Industry', (table)->
        table.dropColumn("max_impressions")

}