module.exports.up = (sequelize, models)->
  
  Promise.map [
    {
      name: "Carbon Business Circle"
      id: 1
      cpm: 2.25
      private: true
    }
    {
      name: "Carbon Dev Circle"
      id: 2
      cpm: 1
      private: true
    }
    {
      name: "Carbon Design Circle"
      id: 3
      cpm: 1
      private: true
    }
  ], (data)->
    models.Industry.findOrCreate({
      where: {
        name: data.name
      },
      defaults: data
    })