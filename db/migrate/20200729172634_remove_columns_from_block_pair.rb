class RemoveColumnsFromBlockPair < ActiveRecord::Migration[6.0]
  def change
    remove_column :block_pairs, :north_sw_coord, :string
    remove_column :block_pairs, :north_ne_coord, :string
    remove_column :block_pairs, :south_sw_coord, :string
    remove_column :block_pairs, :south_ne_coord, :string
  end
end
