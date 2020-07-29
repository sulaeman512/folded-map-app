class AddColumnsToBlockPair < ActiveRecord::Migration[6.0]
  def change
    add_column :block_pairs, :north_sw_lat, :string
    add_column :block_pairs, :north_sw_lng, :string
    add_column :block_pairs, :north_se_lat, :string
    add_column :block_pairs, :north_se_lng, :string
    add_column :block_pairs, :north_ne_lat, :string
    add_column :block_pairs, :north_ne_lng, :string
    add_column :block_pairs, :north_nw_lat, :string
    add_column :block_pairs, :north_nw_lng, :string
    add_column :block_pairs, :south_sw_lat, :string
    add_column :block_pairs, :south_sw_lng, :string
    add_column :block_pairs, :south_se_lat, :string
    add_column :block_pairs, :south_se_lng, :string
    add_column :block_pairs, :south_ne_lat, :string
    add_column :block_pairs, :south_ne_lng, :string
    add_column :block_pairs, :south_nw_lat, :string
    add_column :block_pairs, :south_nw_lng, :string
  end
end
