module.exports = { 

  up: (knex, models)->   
    knex.schema.hasTable('Publisher').then (exists)->
      if not exists then return     
      
      Promise.resolve().then ->
        models.Publisher.destroy({
          where: {
            product: "protect"
            is_demo: true
          }
        })

      .then ->
        models.Publisher.update({
          product: "network"
        }, {
          where: {
            product: "protect"
          }
        })
}