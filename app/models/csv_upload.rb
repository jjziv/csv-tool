class CsvUpload < ApplicationRecord
  has_one_attached :csv_file

  # Add attributes for storing parsed data
  # ...
  # Example:
  # serialize :parsed_data, JSON
end
