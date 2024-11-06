require "csv"

class CsvParser
  ID_FIELD = "sfid"
  CUSTOMER_INFO_HEADERS = ["sfid", "first name", "last name", "address", "city", "state", "zip code", "email", "mobile phone", "sms permission"]

  def initialize(csv_file)
    @csv_file = csv_file
  end

  def parse_and_deduplicate_csv
    combined_data = {}
    headers = []

    CSV.parse(@csv_file.download, headers: true) do |row|
      if headers.empty?
        headers = row.headers
        determine_fields_from_headers(headers)
      end

      customer_key = row[ID_FIELD]
      repeating_data = @repeating_fields.map { |field| row[field] }

      if combined_data.key?(customer_key)
        combined_data[customer_key][:repeating_data].push(repeating_data)
      else
        combined_data[customer_key] = {
          customer_info: row.to_h.slice(*@customer_info_fields),
          repeating_data: [repeating_data]
        }
      end
    end

    generate_csv(combined_data)
  end

  private

  def determine_fields_from_headers(headers)
    # Operating under the assumption that all inputs will have all or a subset of the customer info fields from this example.
    @customer_info_fields = headers.select { |header| CUSTOMER_INFO_HEADERS.include?(header) }
    @repeating_fields = headers - @customer_info_fields - [ID_FIELD]
  end

  def generate_csv(combined_data)
    CSV.generate do |csv|
      base_headers = @customer_info_fields
      max_repeats = combined_data.values.map { |data| data[:repeating_data].size }.max

      repeating_headers = max_repeats.times.flat_map { |i| @repeating_fields.map { |field| "#{field} #{i+1}" } }

      csv << base_headers + repeating_headers
      total_columns_count = base_headers.size + repeating_headers.size

      combined_data.each do |_, data|
        row = data[:customer_info].values
        data[:repeating_data].each { |repeating_group| row += repeating_group }
        row.fill(nil, row.size...total_columns_count)
        csv << row
      end
    end
  end
end
