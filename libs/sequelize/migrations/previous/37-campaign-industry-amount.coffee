module.exports = { 

  up: (knex, models)->   
    knex.schema.hasTable('CampaignIndustry').then (exists)->
      if not exists then return     
      
      knex.schema.table 'CampaignIndustry', (table)->
        table.float("amount", 6, 3).defaultTo(0)


  down: (knex)->
    knex.schema.hasTable('CampaignIndustry').then (exists)->
      if not exists then return
      
      knex.schema.table 'CampaignIndustry', (table)->
        table.dropColumn("amount")
      
}