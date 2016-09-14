module.exports = (sequelize, DataTypes)->
  
  return sequelize.define "Industry", {
    name: DataTypes.STRING
    cpm: {
      type: DataTypes.DECIMAL(6,3)
      defaultValue: 0
      validate: {
        min: {
          args: [ 0 ]
          msg: "CPM must be greater than or equal to 0"
        }
      }
      get: ->      
        return Number @getDataValue("cpm")
    }
    private: { 
      type: DataTypes.BOOLEAN
      defaultValue: false
    }
  }, {
    hooks: {            
      afterUpdate: (industry, options, callback)->               
        LIBS.models.IndustryAudit.create({
          name: industry.previous "name"
          cpm: industry.previous "cpm"
          private: industry.previous "private"
        }).then ->
          callback()
          
        .catch callback

    }
  }