class CreateInstruments < ActiveRecord::Migration[8.0]
  def change
    create_table :instruments do |t|
      t.references :owner, null: false, foreign_key: { to_table: :users }
      t.string :name
      t.string :brand
      t.string :model
      t.integer :category
      t.integer :condition
      t.text :description
      t.decimal :daily_rate, precision: 10, scale: 2
      t.decimal :weekly_rate, precision: 10, scale: 2
      t.decimal :monthly_rate, precision: 10, scale: 2
      t.boolean :available, default: true, null: false
      t.string :location
      t.decimal :latitude, precision: 10, scale: 6
      t.decimal :longitude, precision: 10, scale: 6
      t.string :slug

      t.timestamps
    end
    add_index :instruments, :slug, unique: true
  end
end
