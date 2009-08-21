# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20090730001620) do

  create_table "devices", :force => true do |t|
    t.string   "name"
    t.string   "url"
    t.string   "booth"
    t.text     "description"
    t.boolean  "application"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "devices", ["name"], :name => "index_devices_on_name"

  create_table "images", :force => true do |t|
    t.integer  "size"
    t.string   "content_type"
    t.string   "filename"
    t.integer  "height"
    t.integer  "width"
    t.integer  "parent_id"
    t.string   "thumbnail"
    t.string   "type"
    t.integer  "device_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "images", ["device_id"], :name => "index_images_on_device_id"

end
