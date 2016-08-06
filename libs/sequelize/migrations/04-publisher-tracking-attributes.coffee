module.exports = { 

  up: (knex)->
    knex.schema.table 'Events', (table)-> 
      table.jsonb("cookies").defaultTo("{}")
      table.jsonb("headers").defaultTo("{}")
      table.jsonb("geo_location").defaultTo("{}")
      table.text("referrer_url")
  
  
  down: (knex)->
    knex.schema.table 'Events', (table)-> 
      table.dropColumn("cookies")
      table.dropColumn("headers")
      table.dropColumn("geo_location")
      table.dropColumn("referrer_url")

}