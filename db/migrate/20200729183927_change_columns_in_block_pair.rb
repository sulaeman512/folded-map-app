class ChangeColumnsInBlockPair < ActiveRecord::Migration[6.0]
  def change
    change_column :block_pairs, :north_sw_lat, 'decimal USING CAST(north_sw_lat AS decimal(10,6))'
    change_column :block_pairs, :north_sw_lng, 'decimal USING CAST(north_sw_lat AS decimal(10,6))'
    change_column :block_pairs, :north_se_lat, 'decimal USING CAST(north_sw_lat AS decimal(10,6))'
    change_column :block_pairs, :north_se_lng, 'decimal USING CAST(north_sw_lat AS decimal(10,6))'
    change_column :block_pairs, :north_ne_lat, 'decimal USING CAST(north_sw_lat AS decimal(10,6))'
    change_column :block_pairs, :north_ne_lng, 'decimal USING CAST(north_sw_lat AS decimal(10,6))'
    change_column :block_pairs, :north_nw_lat, 'decimal USING CAST(north_sw_lat AS decimal(10,6))'
    change_column :block_pairs, :north_nw_lng, 'decimal USING CAST(north_sw_lat AS decimal(10,6))'
    change_column :block_pairs, :south_sw_lat, 'decimal USING CAST(north_sw_lat AS decimal(10,6))'
    change_column :block_pairs, :south_sw_lng, 'decimal USING CAST(north_sw_lat AS decimal(10,6))'
    change_column :block_pairs, :south_se_lat, 'decimal USING CAST(north_sw_lat AS decimal(10,6))'
    change_column :block_pairs, :south_se_lng, 'decimal USING CAST(north_sw_lat AS decimal(10,6))'
    change_column :block_pairs, :south_ne_lat, 'decimal USING CAST(north_sw_lat AS decimal(10,6))'
    change_column :block_pairs, :south_ne_lng, 'decimal USING CAST(north_sw_lat AS decimal(10,6))'
    change_column :block_pairs, :south_nw_lat, 'decimal USING CAST(north_sw_lat AS decimal(10,6))'
    change_column :block_pairs, :south_nw_lng, 'decimal USING CAST(north_sw_lat AS decimal(10,6))'
  end
end
