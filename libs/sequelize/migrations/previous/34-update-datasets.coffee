module.exports = { 

  up: (knex)-> 
    Promise.all [
      LIBS.keen.request("delete", "https://api.keen.io/3.0/projects/#{CONFIG.keen.projectId}/datasets/publisher-analytics"),
      LIBS.keen.request("delete", "https://api.keen.io/3.0/projects/#{CONFIG.keen.projectId}/datasets/campaign-analytics")
    ]  
  
}