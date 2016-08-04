module.exports = { 

  up: (knex)->
    knex.schema.hasColumn("Publishers", "is_demo").then (exists)->      
        if exists then return
        
        knex.schema.table 'Publishers', (table)-> 
          table.boolean("is_demo").defaultTo(false)
  
  
  down: (knex)->
    knex.schema.hasColumn("Publishers", "is_demo").then (exists)->      
        if not exists then return
        
        knex.schema.table 'Publishers', (table)->  
          table.dropColumn("is_demo")

}