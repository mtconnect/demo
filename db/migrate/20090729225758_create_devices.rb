class CreateDevices < ActiveRecord::Migration
  def self.up
    create_table :devices do |t|
      t.string :name
      t.string :url
      t.text :description
      t.boolean :application
      t.string :image_file
      t.string :logo_file

      t.timestamps
    end

    add_index :devices, [:name]
  end

  def self.down
    drop_table :devices
  end
end
