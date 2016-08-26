module.exports = ->
  is_prod = process.env.NODE_ENV == "production"
  logging_defaults = {
    development: ":method :url :status :response-time ms"
    production: ':method :req[host]:url :status :response-time ms :remote-addr ":user-agent" ":referrer" :res[content-length] HTTP/:http-version [:date[clf]]'
  }

  return {
    env: process.env
    is_prod: is_prod
    port: process.env.PORT
    
    postgres_url: process.env.DATABASE_URL
    redis_url: process.env.REDISCLOUD_URL
    
    app_name: process.env.APP_NAME
    website_subdomains: [ "local", "www", "dev", "miza", process.env.APP_NAME ]
    ads_denied_message: "It works!"
    
    queue: {
      producer: process.env.RABBITMQ_BIGWIG_TX_URL
      consumer: process.env.RABBITMQ_BIGWIG_RX_URL
    }
    
    loader_io: "loaderio-6c81ca8de1cc26156be3836bb74e6a05"
    
    ads_server: {
      user_agent: "Miza Ad Protection Bot: https://miza.io"
    }
    
    logger: (->  
      if is_prod 
        return logging_defaults.production
        
      return logging_defaults.development
    )()
    
    mixpanel: process.env.MIXPANEL
    stripe: process.env.STRIPE
    
    default_user_access: [
      {
        email: "brian@miza.io"
        is_admin: true
      }, {
        email: "ambrish@miza.io"
        is_admin: true
      }
    ]
    
    disable: {
      express: {
        logger: false and not is_prod
      }
      ads_server: {
        downloader: false and not is_prod
        modifier: false and not is_prod
      }
    }
    
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
    
    legal: {
      privacy: "https://docs.google.com/document/d/15y4HGnX2mcNhq3wtd8WvYZMISyrmNrIxub_wCxzT1TA/pub?embedded=true"
      terms: "https://docs.google.com/document/d/1707xqsMKnh8tOGI584KSWPp87OCIZkeAf8mNXfnrsyQ/pub?embedded=true"
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