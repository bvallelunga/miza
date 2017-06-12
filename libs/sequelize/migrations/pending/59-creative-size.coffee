module.exports = { 

  up: (knex)->   
    knex.schema.hasTable('Creative').then (exists)->
      if not exists then return     

      knex.schema.table 'Creative', (table)->
        table.string("size")
        table.decimal("width", 5, 0)
        table.decimal("height", 5, 0)


  down: (knex)->
    knex.schema.hasTable('Creative').then (exists)->
      if not exists then return

      knex.schema.table 'Creative', (table)->
        table.dropColumn("size")
        table.dropColumn("width")
        table.dropColumn("height")

}