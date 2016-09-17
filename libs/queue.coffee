jackrabbit = require "jackrabbit"

module.exports = {
  
  producer: if CONFIG.disable.queue then null else jackrabbit(CONFIG.queue.producer).default()
  consumer: if CONFIG.disable.queue then null else jackrabbit(CONFIG.queue.consumer).default()
       
  publish: (key, value)->
    if CONFIG.disable.queue
      return Promise.resolve()
    
    @producer.publish(value, { 
      key: key 
    })
    
  consume: (key, on_message)->
    if CONFIG.disable.queue
      return Promise.resolve()
    
    @consumer.queue({ 
      name: key 
      durable: true
    }).consume(on_message)

}