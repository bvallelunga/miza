module.exports = (sequelize, DataTypes)->
  
  return sequelize.define "PublisherReport", {
    interval: {
      type: DataTypes.STRING
      defaultValue: "minute"
    }
    fee: {
      defaultValue: 1
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
    product: DataTypes.STRING
  }, {
    indexes: [
      {
        fields: [
          'created_at'
        ]
        where: {
          deleted_at: null
        }
      }
    ] 
    classMethods: {      
      associate: (models)->
        models.PublisherReport.belongsTo models.Publisher, { 
          as: 'publisher' 
        }
        
      merged_report: ->
        totals = LIBS.models.PublisherReport.build().toJSON()
        totals.impressions_owed = 0
        totals.clicks_owed = 0
        totals.cpc = 0
        totals.empty = true
        totals.interval = "all"
        return totals
      
      merge: (reports)->         
        totals = LIBS.models.PublisherReport.merged_report()
        
        Promise.each reports, (report)->
          totals.cpm += report.cpm * report.fee
          totals.protected += report.protected
          totals.pings_all += report.pings_all
          totals.pings += report.pings
          totals.impressions += report.impressions               
          totals.clicks += report.clicks
          totals.created_at = report.created_at
          totals.updated_at = report.updated_at
          totals.empty = false
          
          if report.impressions_owed?
            totals.impressions_owed += report.impressions_owed
          
          else
            totals.impressions_owed += report.impressions/1000 * report.cpm * report.fee 
          
        .then ->    
          length = Math.max reports.length, 1
          
          totals.cpm = totals.cpm / length
          totals.protected = totals.pings / (totals.pings_all or 1)
          totals.ctr = totals.clicks / (totals.impressions or 1)
          totals.owed = totals.impressions_owed + totals.clicks_owed
                    
          return totals
    }
  }
