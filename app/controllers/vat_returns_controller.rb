class VatReturnsController < ApplicationController
  before_action :authorize_cashnote_request

  def create
    electronic_file = CreateVatElecFile.call(@vat_return_id)
  end
end
