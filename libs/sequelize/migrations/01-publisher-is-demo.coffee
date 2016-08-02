module.exports = { 

  up: (knex)->    
    knex.schema.table 'Publishers', (table)->
      table.boolean("is_demo").defaultTo(false)
  
  
  down: (knex)->
    knex.schema.table 'Publishers', (table)->
      table.dropColumn("is_demo")

}