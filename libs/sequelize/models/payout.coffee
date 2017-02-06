module.exports = (sequelize, DataTypes)->
  
  return sequelize.define "Payout", {
    start_at: DataTypes.DATE
    end_at: DataTypes.DATE
    name: DataTypes.STRING
    note: DataTypes.STRING
    transferred_at: DataTypes.DATE
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
    is_transferred: { 
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
      reports_query: ->
        return {
          interval: "day"
          paid_at: null
          product: "network"
          created_at: {
            $gte: @start_at
            $lte: @end_at
          }
        }
        
      
      publisher_query: ->
        return {
          is_demo: false
          is_activated: true
          product: "network"
        }
    
      
      publishers: ->
        LIBS.models.Publisher.findAll({
          where: @publisher_query()
          paranoid: false
          order: [
            ['name', 'ASC']
          ]
          include: [{
            model: LIBS.models.User
            as: "owner"
          }]
        }).map (publisher)=>
          publisher.reports(@reports_query()).then (report)->
            publisher.report = report.totals
            return publisher
            
        .then (publishers)=>
          @publishers = publishers
          return publishers
      
      
      update_counts: ->     
        @publishers().map (publisher)->
          return publisher.report
        
        .then (reports)->      
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
          
        .then (payout)=>
          Promise.map @publishers, (publisher)->
            segment = (publisher.report.impressions / payout.impressions) or 0
            publisher.report.revenue_amount = payout.revenue_amount * segment
            publisher.report.transfer_amount = payout.transfer_amount * segment
            return publisher
          .then ->
            return payout
            
      
      create_transfers: ->
        if @is_transferred
          return Promise.reject "Payout already transfered!"
      
        Promise.filter @publishers, (publisher)->
          return publisher.report.transfer_amount > 0
        
        .map (publisher)=>
          LIBS.models.Transfer.findOrCreate {
            individualHooks: true
            where: {
              user_id: publisher.owner_id
              publisher_id: publisher.id
              payout_id: @id
              is_transferred: false
            }
            defaults: {
              type: "payout"
              impressions: publisher.report.impressions
              clicks: publisher.report.clicks
              amount: publisher.report.transfer_amount
              note: @note
            }
          }
          
        .then (transfers)=>
          LIBS.models.PublisherReport.update({
            paid_at: new Date()
          }, {
            where: @reports_query() 
          }).then -> transfers
        
        .then (transfers)=>
          @is_transferred = true
          @transfered_at = new Date()
          @save().then -> transfers
          
    }
    
    hooks: {        
      beforeCreate: (payout, options)->
        payout.fee = 0.6
        payout.note = "Thank you for using Miza!"
        
    }
  }