module.exports = require("../template") {
  intervals: [
    ["stripe.register", '* * * * *']
  ]
  config: {
    priority: "medium"
  }
},  (job)-> 
  data = job.attrs.data or {}
  query = {
    stripe_id: null
  }
  
  if data.user?
    query.id = data.user
    
  LIBS.models.User.findAll({
    where: query
  }).then (users)->
    Promise.map users, (user)->
      return user.stripe_generate()
