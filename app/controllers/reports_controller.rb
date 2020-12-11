require 'csv'

class ReportsController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :authenticate_server

  def handle
    # I have to process csv file sent in the request
    # prevent pileup
    if Rails.env.development?
      Entry.delete_all
      Lock.delete_all
    end

    report = params[:report].open # it's a ready to parssing csv file

    csv_options = { col_sep: ',', headers: :first_row }

    CSV.parse(report, csv_options) do |timestamp, lock_id, kind, status_change|
      timestamp = timestamp[1]
      lock_id = lock_id[1]
      kind = kind[1]
      status_change = status_change[1]
      lock = Lock.find_by_id(lock_id)

      if lock
        # if this lock exists? we have to change this status!
        lock.status = status_change
        lock.save
      else
        lock = Lock.create(id: lock_id, kind: kind, status: status_change)
      end

      Entry.create(timestamp: timestamp, status_change: status_change, lock: lock)
    end
    render json: { message: "Congrats, your report has been sent. You have #{Lock.count} locks and #{Entry.count} entries" }
  end

  def authenticate_server
    # how do I authenticate???
    # First, I have to fine the Server instance accossiated with the code_name that was passed down to us in the request??
    code_name = request.headers["X-Server-CodeName"]
    server = Server.find_by(code_name: code_name)
    access_token = request.headers["X-Server-Token"]
    unless server && server.access_token == access_token
      render json: { message: "Wrong Credentials" }
    end
  end
end
