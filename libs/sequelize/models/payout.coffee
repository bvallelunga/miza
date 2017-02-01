module.exports = (sequelize, DataTypes)->
  
  return sequelize.define "Payout", {
    start_at: DataTypes.DATE
    end_at: DataTypes.DATE
    name: DataTypes.STRING
    payout_at: DataTypes.DATE
    sources: {
      type: DataTypes.JSONB
      defaultValue: []
    }
    source_amount: {
      type: DataTypes.BIGINT
      defaultValue: 0
      get: ->      
        return Number @getDataValue("source_amount")
    }
    revenue_amount: {
      type: DataTypes.BIGINT
      defaultValue: 0
      get: ->      
        return Number @getDataValue("revenue_amount")
    }
    transfer_amount: {
      type: DataTypes.BIGINT
      defaultValue: 0
      get: ->      
        return Number @getDataValue("transfer_amount")
    }
    fee: {
      defaultValue: 0
      allowNull: false
      type: DataTypes.DECIMAL(4,3)
      get: ->      
        return Number @getDataValue("fee")
    }
    impressions: {
      type: DataTypes.DECIMAL(15)
      defaultValue: 0
      get: ->      
        return Number @getDataValue("impressions")
    }
    clicks: {
      type: DataTypes.DECIMAL(15)
      defaultValue: 0
      get: ->      
        return Number @getDataValue("clicks")
    }
    is_transfered: { 
      type: DataTypes.BOOLEAN
      defaultValue: false
    } 
  }, {   
    classMethods: {
      associate: (models)->        
        models.Payout.hasMany models.Transfer, { 
          as: 'transfers' 
        }

    }
    
    instanceMethods: {
      publishers: ->
        LIBS.models.Publisher.findAll({
          where: {
           is_demo: false
           is_activated: true
           product: "network"
          }
          paranoid: false
          order: [
            ['name', 'ASC']
          ]
          include: [{
            model: LIBS.models.User
            as: "owner"
          }]
        }).map (publisher)=>
          publisher.reports({
            interval: "day"
            paid_at: null
            created_at: {
              $gte: @start_at
              $lte: @end_at
            }
          }).then (report)->
            publisher.report = report.totals
            return publisher
      
      update_counts: ->
        LIBS.models.PublisherReport.findAll({
          where: {
            interval: "day"
            paid_at: null
            created_at: {
              $gte: @start_at
              $lte: @end_at
            }
          }
        }).then (reports)->      
          LIBS.models.PublisherReport.merge reports
          
        .then (report)=>
          @impressions = report.impressions
          @clicks = report.clicks
          @source_amount = (@sources.map (source)->
            return source.amount
          .reduce ((t, s) -> t + s), 0) or 0
          @revenue_amount = @source_amount * @fee
          @transfer_amount = @source_amount * (1-@fee)
          @save()
    }
    
    hooks: {        
      beforeCreate: (payout, options)->
        payout.fee = 0.6
        
    }
  }