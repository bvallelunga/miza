module.exports = ->
  isProd = process.env.NODE_ENV == "production"
  logging_defaults = {
    development: ":method :url :status :response-time ms"
    production: ':method :req[host]:url :status :response-time ms :remote-addr ":user-agent" ":referrer" :res[content-length] HTTP/:http-version [:date[clf]]'
  }

  return {
    env: process.env
    isProd: isProd
    port: process.env.PORT
    
    postgres_url: process.env.DATABASE_URL
    redis_url: process.env.REDISCLOUD_URL
    
    app_name: process.env.APP_NAME
    website_subdomains: ["local", "www", "dev", "miza", process.env.APP_NAME]
    ads_redirect: "https://miza.io"
    
    queue: {
      producer: process.env.RABBITMQ_BIGWIG_TX_URL
      consumer: process.env.RABBITMQ_BIGWIG_RX_URL
    }
    
    loader_io: "loaderio-6c81ca8de1cc26156be3836bb74e6a05"
    
    logger: (->  
      if isProd 
        return logging_defaults.production
        
      return logging_defaults.development
    )()
    
    mixpanel: process.env.MIXPANEL
    stripe: process.env.STRIPE
    
    default_user_access: [
      {
        email: "vallelungabrian@gmail.com"
        is_admin: true
      }, {
        email: "ambrish@gmail.com"
        is_admin: true
      }
    ]
    
    general: {
      company: "Miza"
      delimeter: " | "
      description: (
        "Watch ads magically reappear on your website with Miza! " + 
        "Let us worry about Ad Blockers, so you can focus on what is important."
      )  
      support: {
        email: "brian@miza.io"
        phone: "(310) 849-2533" 
      }
    }
    
    slack: {
      beta: "https://hooks.slack.com/services/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"
    }
    
    intercom: {
      app_id: process.env.INTERCOM
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