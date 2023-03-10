class InvoicesController < ApplicationController
  before_action :set_invoice, only: %i[show]

  # GET /invoices/1
  def show
    render json: @invoice.as_json.merge(download_url: @invoice.download_url)
  end

  # POST /invoices
  def create
    @invoice = Invoice.new(data: invoice_params)

    if @invoice.save
      render json: @invoice, status: :created, location: @invoice
    else
      render json: @invoice.errors, status: :unprocessable_entity
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_invoice
    @invoice = Invoice.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def invoice_params
    params.require(:invoice).permit(:number, :date, :payment_method, :footer,
                                    company: %i[name address email],
                                    recipient: %i[name address1 address2 email],
                                    lines: %i[name price quantity])
  end
end
