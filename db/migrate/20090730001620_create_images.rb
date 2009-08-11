class CreateImages < ActiveRecord::Migration
  def self.up
    create_table :images do |t|
      t.integer :size  # file size in bytes
      t.string  :content_type   # mime type, ex: application/mp3
      t.string  :filename   # sanitized filename that reference images:
      t.integer :height  # in pixels
      t.integer :width  # in pixels that reference images that will be thumbnailed:
      t.integer :parent_id  # id of parent image (on the same table, a self-referencing foreign-key).
                            # Only populated if the current object is a thumbnail.
      t.string  :thumbnail   # the 'type' of thumbnail this attachment record describes.
      t.string  :type
      
      t.references :device
      t.timestamps
    end
  end

  def self.down
    drop_table :images
  end
end
