Agenda = require('agenda')

# Exports
module.exports = ->
  return new Agenda {
    db: {
      address: CONFIG.mongo_url
      collection: "agenda"
    }
  }