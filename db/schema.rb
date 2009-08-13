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

ActiveRecord::Schema.define(:version => 20090813061912) do

  create_table "devices", :force => true do |t|
    t.string   "name",        :default => ""
    t.string   "url",         :default => ""
    t.text     "description", :default => ""
    t.boolean  "application"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "booth",       :default => ""
  end

  add_index "devices", ["name"], :name => "index_devices_on_name"

  create_table "images", :force => true do |t|
    t.integer  "size",         :default => 0
    t.string   "content_type", :default => ""
    t.string   "filename",     :default => ""
    t.integer  "height",       :default => 0
    t.integer  "width",        :default => 0
    t.integer  "parent_id",    :default => 0
    t.string   "thumbnail",    :default => ""
    t.string   "type",         :default => ""
    t.integer  "device_id",    :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "images", ["device_id"], :name => "index_images_on_device_id"

end
