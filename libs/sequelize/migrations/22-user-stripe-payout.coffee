module.exports = { 

  up: (knex)->   
    knex.schema.hasTable('User').then (exists)->
      if not exists then return     

      knex.schema.table 'User', (table)->
        table.jsonb("stripe_payout")


  down: (knex)->
    knex.schema.hasTable('User').then (exists)->
      if not exists then return

      knex.schema.table 'User', (table)->
        table.dropColumn("stripe_payout")

}