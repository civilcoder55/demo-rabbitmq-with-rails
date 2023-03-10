class InvoiceGeneratorWorker
  include Sneakers::Worker

  from_queue 'workers.invoices.generator', durable: true

  def work(payload)
    data = JSON.parse(payload).with_indifferent_access
    invoice = Invoice.find_by(id: data[:invoice_id])
    create_invoice(invoice, data[:data]) if invoice
    ack!
  end

  private

  def create_invoice(invoice, invoice_data)
    i = generate_invoice(invoice_data)
    path = "/tmp/invoice_#{invoice.id}.pdf"
    i.render_file path
    invoice.file.attach(io: File.open(path), filename: "invoice_#{invoice.id}.pdf", content_type: 'application/pdf')
    invoice.status = :completed
    invoice.save!
  rescue StandardError => e
    puts e
    invoice.failed!
  end

  def generate_invoice(invoice_data)
    lines = invoice_data[:lines].map do |item|
      [item[:name], "$#{item[:price]}", item[:quantity], "$#{item[:price] * item[:quantity]}"]
    end

    Receipts::Invoice.new(
      details: details(invoice_data),
      company: company(invoice_data),
      recipient: recipient(invoice_data),
      line_items: ([['<b>Item</b>', '<b>Unit Cost</b>', '<b>Quantity</b>', '<b>Amount</b>']] + lines),
      footer: invoice_data[:footer]
    )
  end

  def details(invoice_data)
    [
      ['Receipt Number', invoice_data[:number]],
      ['Date paid', Date.parse(invoice_data[:date])],
      ['Payment method', invoice_data[:payment_method]]
    ]
  end

  def company(invoice_data)
    {
      name: invoice_data.dig(:company, :name),
      address: invoice_data.dig(:company, :address),
      email: invoice_data.dig(:company, :email)
    }
  end

  def recipient(invoice_data)
    [
      '<b>Bill To</b>',
      invoice_data.dig(:recipient, :name),
      invoice_data.dig(:recipient, :address1),
      invoice_data.dig(:recipient, :address2),
      invoice_data.dig(:recipient, :email)
    ]
  end
end
