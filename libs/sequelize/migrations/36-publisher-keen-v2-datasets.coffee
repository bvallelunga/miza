module.exports = { 

  up: (knex, models)->       
    Promise.each([
      LIBS.keen.deleteDatasets
      (-> (new Promise (res)-> setTimeout res, 10000)) # Give keen a second to detect deleted datasets
      models.Publisher.keen_datasets
    ], (method)-> Promise.resolve method).catch (error)->
      console.error error.stack
      return Promise.reject error

}