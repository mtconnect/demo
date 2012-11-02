class CreateHourlyUtilizations < ActiveRecord::Migration
  def change
    create_table :hourly_utilizations do |t|
      t.integer  :hour
      t.integer  :utilization
      t.integer  :device_id

      t.timestamps
    end
  end
end
