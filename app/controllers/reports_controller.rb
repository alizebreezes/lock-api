class ReportsController < ApplicationController
  skip_before_action :verify_authenticity_token
  def handle
    render json: { message: "testing" }
  end
end
