module.exports = { 

  up: (knex)->   
    knex.schema.hasTable('Industry').then (exists)->
      if not exists then return     

      knex.schema.table 'Industry', (table)->
        table.dropColumn("cpc")
        table.boolean("private").defaultTo(false)

}