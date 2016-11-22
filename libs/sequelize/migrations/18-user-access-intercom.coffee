module.exports = { 

  up: (knex, models)->   
    knex.schema.hasTable('UserAccess').then (exists)->
      if not exists then return     

      knex.schema.table 'UserAccess', (table)->
        table.string("intercom_id")
        
      .then ->
        models.UserAccess.findAll().each (access)->
          access.add_intercom()

    
  down: (knex, models)->   
    knex.schema.hasTable('UserAccess').then (exists)->
      if not exists then return  
      
      knex.schema.table 'UserAccess', (table)->
        table.dropColumn("intercom_id")
        
      .then ->
        models.UserAccess.findAll().each (access)->
          access.remove_intercom()   

      

}