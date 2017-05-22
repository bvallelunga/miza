module.exports = { 

  up: (knex, models)->
    Promise.all([      
      models.Publisher.keen_datasets()    
    ]).catch (error)->
      console.error error.stack
      return Promise.reject error

}