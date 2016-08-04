module.exports = { 

  up: (knex)->       
    knex.schema.hasColumn("Events", "ad_network").then (exists)->      
        if exists then return
        
        knex.schema.table 'Events', (table)->    
          table.string("ad_network")
  
  
  down: (knex)->
    knex.schema.hasColumn("Events", "ad_network").then (exists)->      
        if not exists then return
        
        knex.schema.table 'Events', (table)->  
          table.dropColumn("ad_network")

}