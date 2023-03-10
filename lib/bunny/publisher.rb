module Bunny
  class Publisher
    def self.fanout(exchange_name, message)
      channel = ConnectionManager.instance.channel
      exchange = channel.fanout(exchange_name)
      exchange.publish(message.to_json)
    end
  end
end
