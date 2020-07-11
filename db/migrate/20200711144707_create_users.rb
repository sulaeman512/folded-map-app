class CreateUsers < ActiveRecord::Migration[6.0]
  def change
    create_table :users do |t|
      t.string :email
      t.string :password_digest
      t.string :first_name
      t.string :last_name
      t.integer :street_num
      t.string :street_direction
      t.string :street
      t.string :zip_code
      t.integer :block_id
      t.string :image_url
      t.text :how_i_got_here
      t.text :what_i_like
      t.text :what_i_would_change
      t.date :birthday

      t.timestamps
    end
  end
end
