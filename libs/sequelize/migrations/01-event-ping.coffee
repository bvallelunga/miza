module.exports = { 

  up: (knex)->
    knex.schema.hasTable('Event').then (exists)->
      if not exists then return 
      
      knex.schema.raw """ALTER TYPE "enum_Event_type" ADD VALUE 'ping';"""
  
  
  down: (knex)->
    knex.schema.hasTable('Event').then (exists)->
      if not exists then return   
      
      knex.schema.raw 'ALTER TYPE "enum_Event_type" ADD VALUE ping;'

}