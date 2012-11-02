class AddIndexes < ActiveRecord::Migration
  def up
    add_index :devices, :name
    add_index :apps, :name
    
    add_index :alarms, :device_id
    add_index :app_pictures, :app_id        

    add_index :cycles, [:device_id, :started, :stopped], :name => "cycle_index", :unique => false
    add_index :hourly_utilizations, [:device_id, :hour], :name => "hourly_utilization_index", :unique => false
  end

  def down
    remove_index :devices, :name
    remove_index :app, :name
    
    remove_index :alarms, :device_id
    remove_index :app_pictures, :app_id
    
    remove_index :cycles, :name => 'cycle_index'
    remove_index :hourly_utilizations, :name => 'hourly_utilization_index'
  end
end