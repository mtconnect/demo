class CreateApps < ActiveRecord::Migration
  def change
    create_table :apps do |t|
      t.string  :name
      t.text    :url
      t.boolean :enabled
      t.text    :description
      t.string  :location
      t.string  :logo

      t.timestamps
    end
  end
end
