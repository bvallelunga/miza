module.exports = { 

  up: (knex)->    
    knex.schema.hasTable('User').then (exists)->
      if not exists then return 

      knex.schema.table 'User', (table)->
        table.boolean("is_demo").defaultTo(false)
        
      .then ->
        knex("User").where('email', "demo@miza.io").update({
          is_demo: true
        })
  
  
  down: (knex)->
    knex.schema.hasTable('User').then (exists)->
      if not exists then return 
      
      knex.schema.table 'User', (table)->
        table.dropColumn("is_demo")

}