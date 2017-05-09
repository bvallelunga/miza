module.exports = { 

  up: (knex)->   
    knex.schema.hasTable('IndustryAudit').then (exists)->
      if not exists then return     

      knex.schema.table 'IndustryAudit', (table)->
        table.dropColumn("cpc")
        table.boolean("private").defaultTo(false)
  
}