module.exports = { 

  up: (knex, models)->       
    models.Campaign.keen_datasets().catch (error)->
      console.error error.stack
      return Promise.reject error

}