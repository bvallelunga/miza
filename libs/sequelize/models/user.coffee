crypto = require 'crypto'

module.exports = (sequelize, DataTypes)->
  hasher = (value)->
    return crypto.createHash('md5').update(value).digest('hex')

  return sequelize.define "User", {
    email: { 
      type: DataTypes.STRING,
      unique: true
      allowNull: false
      validate: {
        isEmail: {
          msg: "Must be valid a email address"
        }
      }
    }
    password: {
      type: DataTypes.STRING
      allowNull: false
      set: (value)->
        @setDataValue 'password', @hash(value) 
    }
    name: DataTypes.STRING 
    stripe_id: DataTypes.STRING
    stripe_card: DataTypes.STRING
    is_admin: { 
      type: DataTypes.BOOLEAN
      defaultValue: false
    } 
  }, {
    classMethods: {
      hash: hasher
      
      associate: (models)->
        models.User.belongsToMany models.Publisher, {
          as: 'publishers'
          through: "UserPublisher"
        }
    }
    instanceMethods: {
      hash: hasher
      
      generate_stripe: ->      
        return LIBS.stripe.customers.create({
          email: this.email
          description: this.name
          metadata: {
            id: this.id
            name: this.name
          }
        }).then (customer)=>
          return this.update({
            stripe_id: customer.id
          })
    
    }
    hooks: {
      afterCreate: (publisher)->
        publisher.generate_stripe().catch console.warn

    }
  }