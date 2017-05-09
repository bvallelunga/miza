module.exports = { 

  up: (knex)->    
    knex.schema.hasTable("IndustryAudit").then (exists)->
      if not exists then return 

      knex.schema.table "IndustryAudit", (table)->
        table.integer('industry_id').unsigned()
        table.foreign("industry_id")
          .references("id")
          .inTable("Industry")
          .onUpdate("CASCADE")
          .onDelete("CASCADE")
  
  
  down: (knex)->
    knex.schema.hasTable("IndustryAudit").then (exists)->
      if not exists then return 
      
      knex.schema.table "IndustryAudit", (table)->
        table.dropForeign("industry_id")

}