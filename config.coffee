module.exports = {
  
  env: process.env
  isProd: process.env.NODE_ENV == "production"
  port: process.env.PORT
  
  postgres_url: process.env.DATABASE_URL
  redis_url: process.env.REDISCLOUD_URL
  
  app_name: process.env.APP_NAME
  website_subdomains: ["www", "dev", "miza", process.env.APP_NAME]
  ads_redirect: "https://miza.io"
  
  logging_defaults: {
    development: ":method :url :status :response-time ms"
    production: ':method :req[host]:url :status :response-time ms :remote-addr ":user-agent" ":referrer" :res[content-length] HTTP/:http-version [:date[clf]]'
  }
  
  queue: {
    producer: process.env.RABBITMQ_BIGWIG_TX_URL
    consumer: process.env.RABBITMQ_BIGWIG_RX_URL
  }
  
  logger: ->  
    if this.isProd 
      return this.logging_defaults.production
      
    return this.logging_defaults.development
  
  general: {
    company: "Miza"
    delimeter: " | "
    description: (
      "Watch ads magically reappear on your website with Miza! " + 
      "Let us worry about Ad Blockers, so you can focus on what is important."
    )  
    support: {
      email: "vallelungabrian@gmail.com"
      phone: "(310) 849-2533" 
    }
  }
  
  intercom: {
    app_id: "jlsf08kq"
  }
  
  promises: {
    warnings: false
    longStackTraces: true
    cancellation: true
    monitoring: true
  }
  
  heroku_token: process.env.HEROKU_API_TOKEN
  
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