Agenda = require('agenda')

# Exports
module.exports = ->
  if not CONFIG.mongo_url?
    return null

  return new Agenda {
    db: {
      address: CONFIG.mongo_url
      collection: "agenda"
    }
  }