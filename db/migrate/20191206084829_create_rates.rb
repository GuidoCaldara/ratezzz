class CreateRates < ActiveRecord::Migration[6.0]
  def change
    create_table :rates do |t|
      t.string :room
      t.date :checkin
      t.date :checkout
      t.integer :price
      t.references :request_date, null: false, foreign_key: true

      t.timestamps
    end
  end
end
