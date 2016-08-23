module.exports = { 

  up: (knex)->    
    knex.schema.table 'Event', (table)->
      table.dropColumn("ad_id")
      table.renameColumn("ad_network", "network_name")
  
  
  down: (knex)->
    knex.schema.table 'Event', (table)->
      table.string("ad_id")
      table.renameColumn("network_name", "ad_network")

}