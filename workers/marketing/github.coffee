module.exports = require("../template") (job)->   
  
  LIBS.github.search.code({ 
    q: "l=HTML&q=cdn.carbonads.com" 
    sort: 'indexed'
    order: 'asc'
    per_page: 2
    page: 1
  }).then (response)->
    Promise.each response.items, (search)->
      LIBS.github.repos.getContent({
        owner: search.repository.owner.login
        repo: search.repository.name
        path: search.path
      }).then (file)->
        content = new Buffer(file.content, 'base64').toString("ascii")
        
        console.log content