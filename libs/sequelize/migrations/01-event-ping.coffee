module.exports = { 

  up: (knex)->    
    knex.schema.raw """ALTER TYPE "enum_Event_type" ADD VALUE 'ping';"""
  
  
  down: (knex)->
    knex.schema.raw 'ALTER TYPE "enum_Event_type" ADD VALUE ping;'

}