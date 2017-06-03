module.exports.get = (req, res, next)->
  res.render "auth/register", {
    js: req.js.renderTags "modal", "fa"
    css: req.css.renderTags "modal"
    title: "Sign Up"
    name: req.query.name or ""
    email: req.query.email or ""
  }


module.exports.post = (req, res, next)->
  email = req.body.email.toLowerCase().trim()
  next_page = "/dashboard"

  if not req.body.type?
    return next "Please select your user type."

  LIBS.models.sequelize.transaction (t)->
    LIBS.models.UserAccess.findAll({
      transaction: t
      where: {
        email: email
      }
    }).then (accesses)->
      if accesses.length == 0 and req.body.type != "demand"
        return next "Sorry, Miza is invite only at this point. Please reach out to our team for an invite!"

      admin_contact = null
      admin_contacts = accesses.filter (access)->
        return access.admin_contact_id?

      if admin_contacts.length > 0
        admin_contact = admin_contacts[0].admin_contact_id

      LIBS.models.User.create({
        email: email
        password: req.body.password
        name: req.body.name
        phone: req.body.phone or null
        type: req.body.type
        admin_contact_id: admin_contact
        is_admin: (accesses.filter (access)->
          return access.is_admin
        .length > 0)
      }, {transaction: t}).then (user)->
        req.user = user
        req.session.user = user.id

        publishers = accesses.filter (access)->
          return access.publisher_id?
        .map (access)->
          return access.publisher_id

        advertisers = accesses.filter (access)->
          return access.advertiser_id?
        .map (access)->
          return access.advertiser_id

        Promise.all([
          user.addPublishers(publishers, {transaction: t}),
          user.addAdvertisers(advertisers, {transaction: t})
        ]).then ->
          LIBS.models.UserAccess.destroy {
            transaction: t
            where: {
              id: {
                $in: accesses.map (access)->
                  return access.id
              }
            }
          }

      .then ->
        if req.body.type == "demand" and req.body.type_engage?
          return LIBS.models.Advertiser.create({
            domain: ""
            name: "#{req.user.name} (#{req.body.type_engage})"
            owner_id: req.user.id
            admin_contact_id: req.user.admin_contact_id
            auto_approve: 1
          }, {transaction: t}).then (advertiser)->
            req.user.addAdvertiser(advertiser)
            if req.useragent.isMobile
              next_page = "/mobile/"

              LIBS.emails.send "mobile_registration", [{
                to: req.user.email
                host: req.get("host")
                data: {
                  user: req.user
                }
              }]
              req.session.destroy()
            else
              next_page = "/dashboard/demand/#{advertiser.key}/campaigns?new_advertiser"
    .then ->
      res.json {
        success: true
        next: next_page
        registration: {
          success: true
          type: "#{req.body.type}_#{req.body.type_engage}".toLowerCase()
        }
      }

  .catch next
