class AddHasUtilization < ActiveRecord::Migration
  def up
    add_column :devices, :has_utilization, :boolean
  end

  def down
    remove_column :devices, :has_utilization
  end
end
