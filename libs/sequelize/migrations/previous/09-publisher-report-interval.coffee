module.exports = { 

  up: (knex)->   
    knex.schema.hasTable('PublisherReport').then (exists)->
      if not exists then return     

      knex.schema.table 'PublisherReport', (table)->
        table.string("interval").defaultTo("minute")


  down: (knex)->
    knex.schema.hasTable('PublisherReport').then (exists)->
      if not exists then return

      knex.schema.table 'PublisherReport', (table)->
        table.dropColumn("interval")

}