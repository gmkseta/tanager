class VatReturnFilesController < ApplicationController
  before_action :authorize_cashnote_request

  def create
    CreateVatReturnElecFileJob.perform_later(@vat_return_id)
    head :ok
  end
end
