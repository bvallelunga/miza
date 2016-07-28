module.exports = {
  
  env: process.env
  isProd: process.env.NODE_ENV == "production"
  port: process.env.PORT
  
  mongo_url: process.env.MONGODB_URI
  redis_url: process.env.REDIS_URL
  
  website_subdomains: ["www", "sledge", process.env.APP_NAME]
  
  general: {
    company: "Sledge"
    delimeter: " | "
    description: (
      "This is sledge"
    )  
  }
  
  cookies: {
    session: (session, redis)->
      RedisStore = require('connect-redis')(session)
        
      return {
        name: "usrs"
        secret: "mfcfdgb2gaa3077598hgilj155ni38539550cb0dimbi1d60i28nbb579ci7if495c3bejbek8i1ab"
        resave: true
        saveUninitialized: false
        store: new RedisStore({ client: redis })
      }
  }
  
}