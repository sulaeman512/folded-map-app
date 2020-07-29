class AddCoordColumnsToBlockPair < ActiveRecord::Migration[6.0]
  def change
    add_column :block_pairs, :north_sw_coord, :string, array: true, default: []
    add_column :block_pairs, :north_ne_coord, :string, array: true, default: []
    add_column :block_pairs, :south_sw_coord, :string, array: true, default: []
    add_column :block_pairs, :south_ne_coord, :string, array: true, default: []
  end
end
