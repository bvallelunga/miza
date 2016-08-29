module.exports = { 

  up: (knex)->    
    knex.schema.hasTable("UserAccess").then (exists)->
      if not exists then return 

      knex.schema.table "UserAccess", (table)->
        table.integer('publisher_id').unsigned()
        table.foreign("publisher_id")
          .references("id")
          .inTable("Publisher")
          .onUpdate("CASCADE")
          .onDelete("CASCADE")
  
  
  down: (knex)->
    knex.schema.hasTable("UserAccess").then (exists)->
      if not exists then return 
      
      knex.schema.table "UserAccess", (table)->
        table.dropForeign("publisher_id")

}