module.exports = { 

  up: (knex, models)->
    LIBS.keen.fetchDefinitions().each (dataset)->
      name = dataset.dataset_name
      
      if name.indexOf(CONFIG.keen.prefix) == -1
        return LIBS.keen.deleteDataset(name)      

}