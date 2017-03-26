numeral = require "numeral"

module.exports = (sequelize, DataTypes)->
  
  return sequelize.define "Payout", {
    start_at: DataTypes.DATE
    end_at: DataTypes.DATE
    name: DataTypes.STRING
    note: DataTypes.STRING
    transferred_at: DataTypes.DATE
    revenue: {
      type: DataTypes.DECIMAL(15,2)
      defaultValue: 0
      get: ->      
        return Number @getDataValue("revenue")
    }
    profit: {
      type: DataTypes.DECIMAL(15,2)
      defaultValue: 0
      get: ->      
        return Number @getDataValue("profit")
    }
    transfer: {
      type: DataTypes.DECIMAL(15,2)
      defaultValue: 0
      get: ->
        return Number @getDataValue("transfer")
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
    metrics: {
      type: DataTypes.VIRTUAL
      get: ->      
        return {
          profit: numeral(@profit).format("$0[,]000.00")
          revenue: numeral(@revenue).format("$0[,]000.00")
          transfer: numeral(@transfer).format("$0[,]000.00")
          impressions: numeral(@impressions).format("0[,]000")
          clicks: numeral(@clicks).format("0[,]000")
          fee: numeral(@fee).format("0[.]0%")
        }
    }
  }, {   
    classMethods: {
      associate: (models)->        
        models.Payout.hasMany models.Transfer, { 
          as: 'transfers' 
        }

    }
    
    instanceMethods: {      
      fetch_publishers: ->
        LIBS.models.Publisher.findAll({
          where: {
            is_activated: true
            product: "network"
            config: {
              keen: {
                $ne: null
              }
            }
          }
          paranoid: false
          order: [
            ['name', 'ASC']
          ]
        })
        
        
      fetch_advertiser_transfers: ->      
        LIBS.models.Transfer.all({
          where: {
            is_transferred: true
            type: "charge"
            payout_id: null
            advertiser_id: {
              $ne: null
            }
          }
          include: [{
            model: LIBS.models.Campaign
            as: "campaign"
            paranoid: false
            where: {
              $or: [{
                end_at: {
                  $lte: @end_at
                }
              }, {
                deleted_at: {
                  $lte: @end_at
                }
              }]
            }
          }]
        })
        
      
      publisher_metrics: (publisher, campaigns)->
        client = LIBS.keen.scopedAnalysis publisher.config.keen
        start_at = @start_at
        
        # Find the real start date, some advertiser
        # transfers take awhile to be approved.
        # In the case an advertiser doesn't pay
        # in net 30 days, this will ensure the publisher
        # is paid in the next month
        for transfer in @advertiser_transfers        
          if transfer.campaign.created_at < start_at
            start_at = transfer.campaign.created_at
            
        run_query = (operation, query)=>
          query.event_collection = "ads.event"
          query.timeframe = {
            start: start_at
            end: @end_at
          }
          query.filters = (query.filters or []).concat([{
            "operator": "eq",
            "property_name": "publisher.id",
            "property_value": publisher.id
          }, {
            "operator": "in",
            "property_name": "campaign.id",
            "property_value": campaigns
          }])
          
          
          client.query(operation, query).then (response)->    
            return response.result
              
        Promise.props({
          revenue: run_query("sum", {
            target_property: "industry.cpm_impression"
            filters: [{
              "operator": "eq",
              "property_name": "type",
              "property_value": "impression"
            }]
          })
          impressions: run_query("count", {
            filters: [{
              "operator": "eq",
              "property_name": "type",
              "property_value": "impression"
            }]
          })
          clicks: run_query("count", {
            filters: [{
              "operator": "eq",
              "property_name": "type",
              "property_value": "clicks"
            }]
          })
        })
        
        
      generate_transfers: ->     
        payout = @
        payout.profit = 0 
        payout.revenue = 0 
        payout.transfer = 0 
        payout.impressions = 0  
        payout.clicks = 0      
      
        Promise.props({
          publishers: @fetch_publishers()
          advertiser_transfers: @fetch_advertiser_transfers()            
        }).then (data)->        
          payout.advertiser_transfers = data.advertiser_transfers
          campaigns = data.advertiser_transfers.map (transfer)->
            transfer.campaign_id
        
          Promise.map data.publishers, (publisher)->
            payout.publisher_metrics(publisher, campaigns).then (metrics)->
              transfer_amount = metrics.revenue * payout.fee * publisher.fee
              transfer = LIBS.models.Transfer.build({
                name: payout.name
                note: payout.note
                amount: transfer_amount
                user_id: publisher.owner_id
                publisher_id: publisher.id
                payout_id: payout.id
                impressions: metrics.impressions
                clicks: metrics.clicks
                type: "payout"
                config: {
                  revenue: metrics.revenue 
                  profit: metrics.revenue - transfer_amount
                }
              })
              transfer.publisher = publisher
              return transfer
            
        .each (transfer)->
          payout.profit += transfer.config.profit
          payout.revenue += transfer.config.revenue
          payout.transfer += transfer.amount
          payout.impressions += transfer.impressions
          payout.clicks += transfer.clicks
          
        .then (transfers)->
          payout.transfers = transfers
          payout.save()
          
        
      fetch_transfers: ->     
        LIBS.models.Transfer.findAll({
          where: {
            type: "payout"
            payout_id: @id
          }
          include: [{
            model: LIBS.models.Publisher
            as: "publisher"
          }]
        }).then (transfers)=>
          @transfers = transfers
            
      
      create_transfers: ->
        if @is_transferred
          return Promise.reject "Payout already transfered!"
        
        @generate_transfers().then (payout)->
          Promise.each payout.advertiser_transfers, (transfer)->
            transfer.payout_id = payout.id
            transfer.save()
            
          .then ->
            return payout.transfers
          
        .filter (transfer)->
          return transfer.amount > 0
        
        .each (transfer)->
          transfer.save()
          
        .then =>
          @is_transferred = true
          @transferred_at = new Date()
          @save()

    }
    
    hooks: {        
      beforeCreate: (payout, options)->
        payout.fee = 0.3
        payout.note = "Thank you for using Miza!"
        
    }
  }