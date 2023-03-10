require "#{Rails.root}/lib/bunny/connection_manager"

channel = Bunny::ConnectionManager.instance.channel

rabbitmq_bindings = Rails.application.config_for(:rabbitmq_bindings)

rabbitmq_bindings.each do |exchange_type, bindings|
  bindings.each do |binding|
    binding.each do |exchange_name, queues_names|
      channel.exchange_delete(exchange_name.to_s)
      channel.exchange_declare(exchange_name.to_s, exchange_type)
      queues_names.each do |queue_name|
        queue = channel.queue(queue_name.to_s, durable: true)
        queue.bind(exchange_name.to_s)
      end
    end
  end
end
