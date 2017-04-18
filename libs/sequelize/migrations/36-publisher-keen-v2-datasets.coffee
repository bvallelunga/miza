module.exports = { 

  up: (knex, models)->       
    Promise.each([
      LIBS.keen.deleteDatasets
      models.Publisher.keen_datasets
    ], (method)-> method()).catch (error)->
      console.error error.stack
      return Promise.reject error

}