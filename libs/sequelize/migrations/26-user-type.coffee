module.exports = { 

  up: (knex, models)->   
    knex.schema.hasTable('User').then (exists)->
      if not exists then return     
      
      Promise.resolve().then ->
        knex.schema.table 'User', (table)->
          table.string("type")
      
      .then ->
        models.User.findAll().each (user)->
          user.update({
            type: "publisher"
          })


  down: (knex)->
    knex.schema.hasTable('User').then (exists)->
      if not exists then return

      knex.schema.table 'User', (table)->
        table.dropColumn("type")

}