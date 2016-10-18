module.exports = (models)->
  Promise.props({
    demo_user: models.User.findOne({
      where: {
        email: "demo@miza.io"
      }
      include: [{
        model: models.Publisher
        as: "publishers"
      }]
    })
    github_user: models.User.findOne({
      where: {
        email: "github@miza.io"
      }
      include: [{
        model: models.Publisher
        as: "publishers"
      }]
    })
    github_publisher_industry: models.Industry.findOne({
      where: {
        name: "Carbon: Dev Circle"
      }
    })
    networks: models.Network.findAll()
  }).then (defaults)->
    defaults.network_ids = defaults.networks.map (network)->
      return network.id
    
    models.defaults = defaults