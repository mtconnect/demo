class AddEnabledFlag < ActiveRecord::Migration
  def self.up
    add_column :devices, :enabled, :boolean, :default => true
  end

  def self.down
    remove_column :devices, :enabled
  end
end
