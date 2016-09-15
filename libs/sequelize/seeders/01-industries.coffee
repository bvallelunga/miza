module.exports.up = (sequelize, models)->
  
  Promise.map [
    {
      name: "Carbon Business Circle"
      id: 1
      cpm: 2.25
    }
    {
      name: "Carbon: Dev Circle"
      id: 2
      cpm: 1
    }
    {
      name: "Carbon: Design Circle"
      id: 3
      cpm: 1
    }
  ], (data)->
    models.Industry.findOrCreate({
      where: {
        name: data.name
      },
      defaults: {
        id: data.id
        cpm: data.cpm
      }
    })