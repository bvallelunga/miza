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
  }).then (defaults)->
    defaults.demo_publishers = {
      protect: defaults.demo_publisher_protect
      network: defaults.demo_publisher_network
    }
    
    models.defaults = defaults