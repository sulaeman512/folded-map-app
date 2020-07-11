class CreateBlocks < ActiveRecord::Migration[6.0]
  def change
    create_table :blocks do |t|
      t.string :name
      t.integer :block_pair_id

      t.timestamps
    end
  end
end
