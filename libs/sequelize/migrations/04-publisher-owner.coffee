module.exports = { 

  up: (knex)->    
    knex.schema.hasTable("Publisher").then (exists)->
      if not exists then return 

      knex.schema.table "Publisher", (table)->
        table.integer('owner_id')
          .unsigned()
          .foreign("owner_id")
          .references("id")
          .inTable("User")
          .onUpdate("CASCADE")
          .onDelete("CASCADE")
  
  
  down: (knex)->
    knex.schema.hasTable("Publisher").then (exists)->
      if not exists then return 
      
      knex.schema.table "Publisher", (table)->
        table.dropForeign("owner_id")

}