jackrabbit = require "jackrabbit"

module.exports = {
  
  producer: jackrabbit(CONFIG.queue.producer).default()
  consumer: jackrabbit(CONFIG.queue.consumer).default()
       
  publish: (key, value)->
    @producer.publish(value, { 
      key: key 
    })
    
  consume: (key, on_message)->
    @consumer.queue({ 
      name: key 
      durable: true
    }).consume(on_message)

}