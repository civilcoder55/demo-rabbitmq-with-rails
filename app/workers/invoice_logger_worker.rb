class InvoiceLoggerWorker
  include Sneakers::Worker

  from_queue 'workers.invoices.logger', durable: true

  def work(payload)
    puts JSON.parse(payload)
    ack!
  end
end
