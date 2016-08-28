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
          email: this.email
          description: this.name
          metadata: {
            id: this.id
            name: this.name
          }
        }).then (customer)=>
          this.stripe_id = customer.id
          return customer
          
      stripe_set_card: (card)->
        return LIBS.stripe.customers.update(this.stripe_id, {
          source: card
        }).then (customer)=>          
          return this.update({
            stripe_card: customer.sources.data[0]
          })
          
      stripe_update: ->
        return LIBS.stripe.customers.update(this.stripe_id, {
          email: this.email
          description: this.name
          metadata: {
            id: this.id
            name: this.name
          }
        })
    
    }
    hooks: {
      beforeCreate: (user, options, callback)->
        user.stripe_generate().then ->
          callback()        
        
        .catch callback
        
        
      afterCreate: (user, options)->
        if not user.is_demo and not user.is_admin
          LIBS.slack.message {
            text: "#{user.name} created an account with email #{user.email}"
          }
       
         
      afterUpdate: (user, options, callback)->
        if user.changed("name") or user.changed("email")
          console.log "update stripe"
          user.stripe_update().then ->
            callback()        
        
          .catch callback
          
        return callback()
        
    }
  }