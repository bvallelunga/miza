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
    demo_publisher: models.Publisher.findOne({
      where: {
        is_demo: true
        product: "network"
      }
    })
  }).then (defaults)->
    models.defaults = defaults