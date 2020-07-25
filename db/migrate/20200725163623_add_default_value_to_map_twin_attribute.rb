class AddDefaultValueToMapTwinAttribute < ActiveRecord::Migration[6.0]
  def change
    change_column :conversations, :map_twin, :boolean, default: false
  end
end
