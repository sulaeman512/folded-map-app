class AddNameToBlockPair < ActiveRecord::Migration[6.0]
  def change
    add_column :block_pairs, :name, :string
  end
end
