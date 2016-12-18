module.exports = { 

  up: (knex, models)->   
    knex.schema.hasTable('PublisherReport').then (exists)->
      if not exists then return     
      
      Promise.resolve().then ->
        knex.schema.table 'PublisherReport', (table)->
          table.string("product")
          
      .then ->
        models.PublisherReport.update {
          product: "protect"
        }, {
          where: {
            product: null
          }
        }

    
  down: (knex)->   
    knex.schema.hasTable('PublisherReport').then (exists)->
      if not exists then return     

      knex.schema.table 'PublisherReport', (table)->
        table.dropColumn("product")

}