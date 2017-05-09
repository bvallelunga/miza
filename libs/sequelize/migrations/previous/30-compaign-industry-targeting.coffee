module.exports = { 

  up: (knex)->   
    knex.schema.hasTable('CampaignIndustry').then (exists)->
      if not exists then return     

      knex.schema.table 'CampaignIndustry', (table)->
        table.jsonb("targeting").defaultTo("{}")


  down: (knex)->
    knex.schema.hasTable('CampaignIndustry').then (exists)->
      if not exists then return

      knex.schema.table 'CampaignIndustry', (table)->
        table.dropColumn("targeting")

}