# app/controllers/csv_uploads_controller.rb
require 'csv'

class CsvUploadsController < ApplicationController
  def new
    @csv_upload = CsvUpload.new
  end

  def create
    @csv_upload = CsvUpload.new(csv_upload_params)

    if @csv_upload.save
      parser = CsvParser.new(@csv_upload.csv_file)
      @csv_upload.parsed_data = parser.parse_and_deduplicate_csv

      if @csv_upload.save
        redirect_to csv_upload_path(@csv_upload), notice: 'CSV uploaded and processed successfully.'
      else
        render :new, status: :unprocessable_entity
      end
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @csv_upload = CsvUpload.find(params[:id])
  end

  def download_csv
    @csv_upload = CsvUpload.find(params[:id])
    if @csv_upload.parsed_data.present?
      send_data @csv_upload.parsed_data, filename: "parsed_data.csv", type: "text/csv", disposition: 'attachment', status: 200
    else
      redirect_to csv_upload_path(@csv_upload), alert: 'CSV data not available for download.'
    end
  end

  private

  def csv_upload_params
    params.require(:csv_upload).permit(:csv_file)
  end
end
