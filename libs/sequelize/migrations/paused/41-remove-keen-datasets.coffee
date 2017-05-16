module.exports = { 

  up: (knex, models)->
    LIBS.keen.fetchDefinitions().each (dataset)->
      name = dataset.dataset_name
      
      if name.indexOf("v2") > -1
        return LIBS.keen.deleteDataset(name)      

}