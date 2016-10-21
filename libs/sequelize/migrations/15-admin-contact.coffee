module.exports = { 

  up: (knex)->   
    knex.schema.hasTable("User").then (exists)->
      if not exists then return 
  
      Promise.resolve().then -> 
        knex.schema.hasTable("Publisher").then (exists)->
          if not exists then return 
    
          knex.schema.table "Publisher", (table)->
            table.integer('admin_contact_id').unsigned()
            table.foreign("admin_contact_id")
              .references("id")
              .inTable("User")
              .onUpdate("CASCADE")
              .onDelete("CASCADE")
              
      .then ->  
          knex.schema.table "User", (table)->
            table.integer('admin_contact_id').unsigned()
            table.foreign("admin_contact_id")
              .references("id")
              .inTable("User")
              .onUpdate("CASCADE")
              .onDelete("CASCADE")
              
      .then ->
        knex.schema.hasTable("UserAccess").then (exists)->
          if not exists then return 
    
          knex.schema.table "UserAccess", (table)->
            table.integer('admin_contact_id').unsigned()
            table.foreign("admin_contact_id")
              .references("id")
              .inTable("User")
              .onUpdate("CASCADE")
              .onDelete("CASCADE")
  
  
  down: (knex)->        
    knex.schema.hasTable("User").then (exists)->
      if not exists then return 
  
      Promise.resolve().then -> 
        knex.schema.hasTable("Publisher").then (exists)->
          if not exists then return 
    
          table.dropForeign("admin_contact_id")              
      .then ->  
          table.dropForeign("admin_contact_id")
              
      .then ->
        knex.schema.hasTable("UserAccess").then (exists)->
          if not exists then return 
    
          table.dropForeign("admin_contact_id")

}