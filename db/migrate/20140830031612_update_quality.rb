class UpdateQuality < ActiveRecord::Migration
  def change
    remove_column :devices, :inspection_plans
    remove_column :devices, :inspection_results
    add_column :devices, :quality_report, :string
  end
end
