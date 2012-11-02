class AddAssetAndUtilColumns < ActiveRecord::Migration
  def up
    add_column :devices, :cutting_tool, :string
    add_column :devices, :inspection_plans, :string
    add_column :devices, :inspection_results, :string
    add_column :devices, :daily_utilization, :integer
  end

  def down
    remove_column :devices, :cutting_tool
    remove_column :devices, :inspection_plans
    remove_column :devices, :inspection_results
    remove_column :devices, :daily_utilization
  end
end