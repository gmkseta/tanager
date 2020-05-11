class HometaxController < ApplicationController
  before_action :authorize_owl_request
  def scraped_callback
    head :ok
  end
end
