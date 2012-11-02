class CreateCycles < ActiveRecord::Migration
  def change
    create_table :cycles do |t|
      t.integer :device_id
      
      t.integer :started
      t.integer :stopped
      
      t.timestamps
    end
  end
end
