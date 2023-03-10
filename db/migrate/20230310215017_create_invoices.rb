class CreateInvoices < ActiveRecord::Migration[7.0]
  def change
    create_table :invoices do |t|
      t.integer :status, default: 0
      t.timestamps
    end
  end
end
