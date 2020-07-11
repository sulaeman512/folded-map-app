class CreatePosts < ActiveRecord::Migration[6.0]
  def change
    create_table :posts do |t|
      t.integer :block_pair_id
      t.integer :user_id
      t.text :text
      t.string :image_url

      t.timestamps
    end
  end
end
