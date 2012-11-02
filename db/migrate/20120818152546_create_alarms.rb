class CreateAlarms < ActiveRecord::Migration
  def change
    create_table :alarms do |t|
      t.integer  :device_id
      t.datetime :time
      t.datetime :cleared
      t.string   :data_item_id
      t.string   :alarm_type
      t.string    :severity
      t.string    :code
      t.string    :description

      t.timestamps
    end
  end
end
