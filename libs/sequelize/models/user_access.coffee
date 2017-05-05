module.exports = (sequelize, DataTypes)->

  return sequelize.define "UserAccess", {
    email: { 
      type: DataTypes.STRING,
      allowNull: false
      validate: {
        isEmail: {
          msg: "Must be valid a email address"
        }
      }
    }
    is_admin: { 
      type: DataTypes.BOOLEAN
      defaultValue: false
    } 
    intercom_id: DataTypes.STRING
  }, {    
    classMethods: {      
      associate: (models)->
        models.UserAccess.belongsTo models.Publisher, { 
          as: 'publisher' 
        }
        
        models.UserAccess.belongsTo models.User, { 
          as: 'admin_contact' 
        }
        
        models.UserAccess.belongsTo models.Advertiser, {
          as: 'advertiser'
        }
        
    }
    instanceMethods: {      
      intercom: ->   
        return Promise.resolve {
          email: @email
          created_at: @created_at
          custom_attributes: {
            admin: if @admin_contact? then @admin_contact.name else ""
          }
        }
        
      add_intercom: ->
        if @is_admin or @publisher_id
          return Promise.resolve()
      
        @intercom().then (intercom)=>
          LIBS.intercom.createContact(intercom).then (response)=>
            @intercom_id = response.id
            @save()
            
      remove_intercom: ->
        if not @intercom_id
          return Promise.resolve()
        
        LIBS.intercom.deleteContact {
          id: @intercom_id
        }
    
    }
    hooks: {        
      afterCreate: (access)->
        access.add_intercom()
       
      afterDestroy: (access)->
        access.remove_intercom()
        
    }
  }