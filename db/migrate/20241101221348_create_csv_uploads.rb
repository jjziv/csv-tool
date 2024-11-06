class CreateCsvUploads < ActiveRecord::Migration[7.2]
  def change
    create_table :csv_uploads do |t|
      t.string :parsed_data, null: true

      t.timestamps
    end
  end
end
