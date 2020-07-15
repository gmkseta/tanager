class VatReturnFilesController < ApplicationController
  before_action :authorize_cashnote_request

  def create
    head :ok    
  end
end
