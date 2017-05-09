module.exports = { 

  up: (knex, models)->   
    knex.schema.hasTable('Publisher').then (exists)->
      if not exists then return     
      
      Promise.resolve().then ->
        knex.schema.table 'Publisher', (table)->
          table.string("product")
          
      .then ->
        models.Publisher.update {
          product: "protect"
        }, {
          where: {
            product: null
          }
        }

    
  down: (knex)->   
    knex.schema.hasTable('Publisher').then (exists)->
      if not exists then return     

      knex.schema.table 'Publisher', (table)->
        table.dropColumn("product")

}