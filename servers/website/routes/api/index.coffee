module.exports.login = (req, res, next)->
  req.mobile_api = true
  
  LIBS.models.User.findOne({
    where: {
      email: (req.body.email or "").toLowerCase().trim()
      password: LIBS.models.User.hash (req.body.password or "")
    }
  }).then (user)->  
    if not user? or not user.is_admin
      return next "Invalid credentials"
          
    res.json {
      success: true
      token: "#{user.id}_#{user.password}"
    }
    
  .catch next
  
  
module.exports.auth = (req, res, next)->
  token = req.query.token.split("_")
  
  LIBS.models.User.findOne({
    where: {
      id: token[0]
      password: token[1]
    }
  }).then (user)->      
    if not user? or not user.is_admin
      return next "Invalid credentials"
    
    req.user = user
    next()
    
  .catch next
  

module.exports.has_publisher = (req, res, next)->
  return LIBS.models.Publisher.findOne({
    where: {
      key: req.params.publisher
    }
  }).then (publisher)->
    req.publisher = publisher
    next()
  
  .catch next
  
  
module.exports.publishers = (req, res, next)->
  LIBS.models.Publisher.findAll({
    include: [{
      model: LIBS.models.User
      as: "owner"
    }]
    order: [
      ['fee', 'DESC']
      ['name', 'ASC']
    ]
  }).then (publishers)->
    res.json {
      success: true
      publishers: publishers.map (publisher)->
        return {
          key: publisher.key
          name: publisher.name
          owner: publisher.owner.name
        }
    }
    

module.exports.publisher = (req, res, next)->
  res.render("api/publisher", {
    js: req.js.renderTags("dashboard", "supply", "keen", "date-range", "api")
    css: req.css.renderTags("dashboard", "supply", "keen", "date-range", "api")
    user_simulate: true
    config: {
      publisher: req.publisher.key
      analytics_endpoint: "/api/publishers/#{req.publisher.key}/charts?token=#{req.query.token}"
    }
  })
    
