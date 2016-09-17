module.exports = ->
  # Set Timezone to PDT
  process.env.TZ = 'America/Los_Angeles' 

  is_prod = process.env.NODE_ENV == "production"
  is_dev = not is_prod
  logging_defaults = {
    development: ":method :url :status :response-time ms"
    production: ':method :req[host]:url :status :response-time ms :remote-addr ":user-agent" ":referrer" :res[content-length] HTTP/:http-version [:date[clf]]'
  }

  return {
    env: process.env
    is_prod: is_prod
    is_dev: is_dev
    port: process.env.PORT or 3030
    concurrency: process.env.WEB_CONCURRENCY or 1
    args: process.argv.slice(2)
    
    mongo_url: process.env.MONGODB_URI
    redis_url: process.env.REDISCLOUD_URL
    postgres: {
      url: process.env.DATABASE_URL
      ssl: process.env.DATABASE_URL.indexOf("localhost") == -1
      flush: false and is_dev
    }
    
    protected: process.env.APP_NAME.indexOf("dev") > -1
    app_name: process.env.APP_NAME
    website_subdomains: [ "local", "www", "dev", "miza", process.env.APP_NAME ]
    
    basic_auth: {
      username: "admin@miza.io"
      password: "1Burrito2Go"
    }
    
    queue: {
      producer: process.env.RABBITMQ_BIGWIG_TX_URL
      consumer: process.env.RABBITMQ_BIGWIG_RX_URL
    }
    
    loader_io: "loaderio-6c81ca8de1cc26156be3836bb74e6a05"
    
    ads_server: {
      domain: process.env.ADS_DOMAIN
      protected_domain: "misosoup.io"
      user_agent: "Miza Ad Protection Bot: https://miza.io"
      denied: {
        message: "It works!"
        redirect: "http://misosoup.com"
      }
    }
    
    reporting_worker: {
      interval: 1 * 60 * 1000 # 1 minute
    }
    
    tracking_worker: {
      interval: 10 * 1000 # 10 seconds
    }
    
    logger: (->  
      if is_prod 
        return logging_defaults.production
        
      return logging_defaults.development
    )()
    
    mixpanel: {
      key: process.env.MIXPANEL
      secret: process.env.MIXPANEL_SECRET
    }
    
    stripe: process.env.STRIPE
    changelog: "ypg6GJ"
    
    default_user_access: [
      {
        email: "brian@miza.io"
        is_admin: true
        publisher: 1
      }, {
        email: "ambrish@miza.io"
        is_admin: true
        publisher: 1
      }
    ]
    
    disable: {
      heroku: false and is_dev
      queue: false and is_dev
      slack: true and is_dev
      express: {
        protected: true and is_dev
        logger: true and is_dev
      }
      ads_server: {
        downloader: true and is_dev
        modifier: false and is_dev
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
    
    sendgrid: {
      api_key: "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"
      from: "Support <support@miza.io>"
    }
    
    promises: {
      warnings: false
      longStackTraces: true
      cancellation: true
      monitoring: true
    }
    
    heroku_token: "bfc62d15-e97d-45e3-b502-0ae2abd7fcdf"
    
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