module.exports = { 

  up: (knex)->
    knex.schema.hasColumn("Publishers", "coverage_ratio").then (exists)->      
        if exists then return
        
        knex.schema.table 'Publishers', (table)-> 
          table.decimal("coverage_ratio", 4, 2).defaultTo(1)
  
  
  down: (knex)->
    knex.schema.hasColumn("Publishers", "coverage_ratio").then (exists)->      
        if not exists then return
        
        knex.schema.table 'Publishers', (table)->  
          table.dropColumn("coverage_ratio")

}