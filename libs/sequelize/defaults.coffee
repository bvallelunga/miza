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
    demo_publisher_network: models.Publisher.findOne({
      where: {
        is_demo: true
        product: "network"
      }
    })
    demo_publisher_protect: models.Publisher.findOne({
      where: {
        is_demo: true
        product: "protect"
      }
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
        name: "Carbon Dev Circle"
      }
    })
    networks: models.Network.findAll()
    carbon_network: models.Network.findOne({
      where: {
        slug: "carbon"
      }
    })
  }).then (defaults)->
    defaults.network_ids = defaults.networks.map (network)->
      return network.id
      
    defaults.demo_publishers = {
      protect: defaults.demo_publisher_protect
      network: defaults.demo_publisher_network
    }
    
    models.defaults = defaults