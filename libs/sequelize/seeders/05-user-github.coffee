randomstring = require "randomstring"

module.exports.up = (sequelize, models)->

  models.User.findOrCreate({
    where: {
      email: "github@miza.io"
    },
    defaults: {
      password: randomstring.generate(15)
      name: "Github Placeholder"
    }
  })
