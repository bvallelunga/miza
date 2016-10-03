module.exports = { 

  up: (knex)->   
    knex.schema.hasTable('User').then (exists)->
      if not exists then return     

      knex.schema.table 'User', (table)->
        table.jsonb("notifications").defaultTo("{}")


  down: (knex)->
    knex.schema.hasTable('User').then (exists)->
      if not exists then return

      knex.schema.table 'User', (table)->
        table.dropColumn("notifications")

}