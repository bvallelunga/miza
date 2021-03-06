crypto = require 'crypto'
phoneFormatter = require 'phone-formatter'

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
    type: { 
      type: DataTypes.STRING,
      allowNull: false
      validate: {
        isIn: {
          msg: "Must be valid user type"
          args: [['supply', 'demand', 'all']]
        }
      }
    }
    phone: {
      type: DataTypes.STRING
      set: (value)->
        if not value?
          return @setDataValue 'phone', null
      
        value = phoneFormatter.normalize value
        @setDataValue 'phone', value
    }
    paypal: DataTypes.STRING
    stripe_id: DataTypes.STRING
    stripe_card: {
      type: DataTypes.JSONB
      get: ->
        card = @getDataValue "stripe_card"
        if not card? then return null
        
        return "#{card.brand} #{card.last4}"
        
      set: (value)->
        LIBS.slack.message {
          text: "#{@name} updated his billing information"
        }
        
        @setDataValue 'stripe_card', value
  
    }
    stripe_payout: {
      type: DataTypes.JSONB
      get: ->
        card = @getDataValue "stripe_payout"
        if not card? then return null
        
        return "#{card.brand} #{card.last4}"
        
      set: (value)->
        LIBS.slack.message {
          text: "#{@name} updated his payout information"
        }
        
        @setDataValue 'stripe_payout', value
  
    }
    is_demo: { 
      type: DataTypes.BOOLEAN
      defaultValue: false
    }
    is_admin: { 
      type: DataTypes.BOOLEAN
      defaultValue: false
    } 
    notifications: {
      type: DataTypes.JSONB
      defaultValue: {}
    }
  }, {
    classMethods: {
      hash: hasher
      
      associate: (models)->
        models.User.belongsToMany models.Publisher, {
          as: 'publishers'
          through: "UserPublisher"
        }
        
        models.User.belongsToMany models.Advertiser, {
          as: 'advertisers'
          through: "UserAdvertiser"
        }
        
        models.User.belongsTo models.User, { 
          as: 'admin_contact' 
        }

    }
    instanceMethods: {
      hash: hasher
      
      stripe_generate: (override)-> 
        if @stripe_id? and not override?
          return Promise.resolve @
      
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
          
      stripe_billing_card: (card)->
        @stripe_generate().then =>
          return LIBS.stripe.customers.update(@stripe_id, {
            source: card.id
          }).then (customer)=>                
            return @update({
              stripe_card: card.card
            })
          
      stripe_payout_card: (card)->      
        @stripe_generate().then =>
          if card.card.funding != "debit"
            return Promise.reject "Please use a debit card."
        
          return LIBS.stripe.customers.createSource(@stripe_id, {
            source: card.id
          }).then (customer)=>                
            return @update({
              stripe_payout: card.card
            })
          
      stripe_update: ->
        @stripe_generate().then =>
          return LIBS.stripe.customers.update(@stripe_id, {
            email: @email
            description: @name
            metadata: {
              id: @id
              name: @name
            }
          })
      
      
      intercom: (api)->   
        if not api
          return Promise.resolve {
            name: @name
            email: @email
            user_id: @id
          }
        
        Promise.resolve().then =>
          if @publishers?
            return Promise.resolve()
          
          @getPublishers().then (publishers)=>
            @publishers = publishers
        
        .then =>
          return {
            user_id: @id
            name: @name
            email: @email
            created_at: @created_at
            companies: @publishers.map (publisher)->
              return {
                id: publisher.key
              }
            custom_attributes: {
              type: @type
              phone: @phone
              stripe: @stripe_id
              card: !!@stripe_card
              paypal: @paypal
            }
          }
    
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