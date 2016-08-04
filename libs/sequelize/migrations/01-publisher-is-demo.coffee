module.exports = { 

  up: (knex)->     
    knex.schema.table 'Publishers', (table)->
      table.hasColumn("is_demo").then (exists)->
        if not exists
          table.boolean("is_demo").defaultTo(false)
  
  
  down: (knex)->
    knex.schema.table 'Publishers', (table)->
      table.hasColumn("is_demo").then (exists)->
        if exists
          table.dropColumn("is_demo")

}