class CreateRentals < ActiveRecord::Migration[8.0]
  def change
    create_table :rentals do |t|
      t.references :instrument, null: false, foreign_key: true
      t.references :renter, null: false, foreign_key: { to_table: :users }
      t.date :start_date
      t.date :end_date
      t.decimal :total_amount, precision: 10, scale: 2
      t.integer :status, default: 0, null: false
      t.string :payment_intent_id

      t.timestamps
    end
  end
end
