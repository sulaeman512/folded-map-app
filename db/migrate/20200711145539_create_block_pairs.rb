class CreateBlockPairs < ActiveRecord::Migration[6.0]
  def change
    create_table :block_pairs do |t|
      t.integer :ew_max
      t.integer :ns_max

      t.timestamps
    end
  end
end
