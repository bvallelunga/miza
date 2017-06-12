module.exports = { 

  up: (knex, models)->   
    knex.schema.hasTable('Creative').then (exists)->
      if not exists then return     

      models.Creative.update({
        format: "image"
        size: "300x250"
        width: 300
        height: 250
      }, {
        where: {
          format: "300 x 250"
        }
      })


  down: (knex)->
    knex.schema.hasTable('Creative').then (exists)->
      if not exists then return

      models.Creative.update({
        format: "300 x 250"
      }, {
        where: {
          format: "image"
        }
      })
}