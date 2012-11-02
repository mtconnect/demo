# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20120907202214) do

  create_table "alarms", :force => true do |t|
    t.integer  "device_id"
    t.datetime "time"
    t.datetime "cleared"
    t.string   "data_item_id"
    t.string   "alarm_type"
    t.string   "severity"
    t.string   "code"
    t.string   "description"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  add_index "alarms", ["device_id"], :name => "index_alarms_on_device_id"

  create_table "app_pictures", :force => true do |t|
    t.string   "file"
    t.integer  "app_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "app_pictures", ["app_id"], :name => "index_app_pictures_on_app_id"

  create_table "apps", :force => true do |t|
    t.string   "name"
    t.text     "url"
    t.boolean  "enabled"
    t.text     "description"
    t.string   "location"
    t.string   "logo"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  add_index "apps", ["name"], :name => "index_apps_on_name"

  create_table "cycles", :force => true do |t|
    t.integer  "device_id"
    t.integer  "started"
    t.integer  "stopped"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "cycles", ["device_id", "started", "stopped"], :name => "cycle_index"

  create_table "daily_utilizations", :force => true do |t|
    t.integer  "utilization"
    t.integer  "device_id"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "devices", :force => true do |t|
    t.string   "name"
    t.text     "url"
    t.boolean  "enabled"
    t.text     "description"
    t.string   "location"
    t.string   "logo"
    t.string   "picture"
    t.integer  "on_time"
    t.integer  "off_time"
    t.boolean  "in_cycle",           :default => false
    t.datetime "created_at",                            :null => false
    t.datetime "updated_at",                            :null => false
    t.string   "cutting_tool"
    t.string   "inspection_plans"
    t.string   "inspection_results"
    t.integer  "daily_utilization"
    t.boolean  "has_utilization"
  end

  add_index "devices", ["name"], :name => "index_devices_on_name"

  create_table "hourly_utilizations", :force => true do |t|
    t.integer  "hour"
    t.integer  "utilization"
    t.integer  "device_id"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  add_index "hourly_utilizations", ["device_id", "hour"], :name => "hourly_utilization_index"

  create_table "utilizations", :force => true do |t|
    t.integer  "device_id"
    t.boolean  "in_cycle"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

end
