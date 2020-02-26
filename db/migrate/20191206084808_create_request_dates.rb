class CreateRequestDates < ActiveRecord::Migration[6.0]
  def change
    create_table :request_dates do |t|
      t.date :date
      t.references :hotel, null: false, foreign_key: true

      t.timestamps
    end
  end
end