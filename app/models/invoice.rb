class Invoice < ApplicationRecord
  has_one_attached :file

  enum status: { in_progress: 0, completed: 1, failed: 2 }

  after_create_commit :queue_invoice

  attr_accessor :data

  def download_url
    ActiveStorage::Current.host = '127.0.0.1:3000'
    file.attached? ? file.blob.url : ''
  end

  private

  def queue_invoice
    Bunny::Publisher.fanout('app.invoices', { invoice_id: id, data: })
  end
end
