class CreateAppPictures < ActiveRecord::Migration
  def change
    create_table :app_pictures do |t|
      t.string :file
      t.integer :app_id

      t.timestamps
    end
  end
end
