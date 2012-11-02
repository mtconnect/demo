class CreateDevices < ActiveRecord::Migration
  def change
    create_table :devices do |t|
      t.string  :name
      t.text    :url
      t.boolean :enabled
      t.text    :description
      t.string  :location
      t.string  :logo
      t.string  :picture
      t.integer :on_time
      t.integer :off_time
      t.boolean :in_cycle, :default => false

      t.timestamps
    end
  end
end
