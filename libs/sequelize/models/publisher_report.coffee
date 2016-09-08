module.exports = (sequelize, DataTypes)->
  
  return sequelize.define "PublisherReport", {
    interval: {
      type: DataTypes.STRING
      defaultValue: "minute"
    }
    fee: {
      defaultValue: 0
      allowNull: false
      type: DataTypes.DECIMAL(4,3)
      get: ->      
        return Number @getDataValue("fee")
    }
    cpm: {
      defaultValue: 0
      allowNull: false
      type: DataTypes.DECIMAL(6,3)
      get: ->      
        return Number @getDataValue("cpm")
    }
    pings_all: {
      defaultValue: 0
      allowNull: false
      type: DataTypes.DECIMAL(13)
      get: ->      
        return Number @getDataValue("pings_all")
    }
    pings: {
      defaultValue: 0
      allowNull: false
      type: DataTypes.DECIMAL(13)
      get: ->      
        return Number @getDataValue("pings")
    }
    impressions: {
      defaultValue: 0
      allowNull: false
      type: DataTypes.DECIMAL(13)
      get: ->      
        return Number @getDataValue("impressions")
    }
    clicks: {
      defaultValue: 0
      allowNull: false
      type: DataTypes.DECIMAL(13)
      get: ->      
        return Number @getDataValue("clicks")
    }
    paid_at: DataTypes.DATE
  }, {
    classMethods: {      
      associate: (models)->
        models.PublisherReport.belongsTo models.Publisher, { 
          as: 'publisher' 
        }
      
      merge: (reports)->      
        totals = LIBS.models.PublisherReport.build().toJSON()
        
        Promise.each reports, (report)->        
          totals.fee += report.fee
          totals.cpm += report.cpm
          totals.protected += report.protected
          totals.pings_all += report.pings_all
          totals.pings += report.pings
          totals.impressions += report.impressions
          totals.clicks += report.clicks
          
        .then ->    
          length = Math.max reports.length, 1
          
          totals.fee = totals.fee / length
          totals.cpm = totals.cpm / length
          totals.protected = totals.pings / (totals.pings_all or 1)
          totals.ctr = totals.clicks / (totals.impressions or 1)
          totals.impressions_revenue = totals.impressions/1000 * totals.cpm
          #totals.cpc = totals.cpm / ((1000 * totals.ctr) or 1)
          #totals.clicks_revenue = totals.clicks * totals.cpc
          totals.revenue = totals.impressions_revenue # + totals.clicks_revenue
          totals.owed = totals.revenue * totals.fee
                    
          return totals
    }
  }
