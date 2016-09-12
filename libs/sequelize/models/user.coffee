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
    stripe_card: DataTypes.JSONB
    is_demo: { 
      type: DataTypes.BOOLEAN
      defaultValue: false
    }
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
      
      stripe_generate: ->      
        return LIBS.stripe.customers.create({
          email: @email
          description: @name
          metadata: {
            id: @id
            name: @name
          }
        }).then (customer)=>
          @stripe_id = customer.id
          return @save()
          
      stripe_set_card: (card)->
        return LIBS.stripe.customers.update(@stripe_id, {
          source: card
        }).then (customer)=>          
          return @update({
            stripe_card: customer.sources.data[0]
          })
          
      stripe_update: ->
        return LIBS.stripe.customers.update(@stripe_id, {
          email: @email
          description: @name
          metadata: {
            id: @id
            name: @name
          }
        })
    
    }
    hooks: {        
      afterCreate: (user, options)->
        LIBS.agenda.now "stripe.register", { user: user.id }
      
        if not user.is_demo and not user.is_admin
          LIBS.slack.message {
            text: "#{user.name} created an account with email #{user.email}"
          }
       
         
      afterUpdate: (user, options, callback)->
        if user.changed("name") or user.changed("email")
          user.stripe_update().then ->
            callback()        
        
          .catch callback
          
        return callback()
        
    }
  }