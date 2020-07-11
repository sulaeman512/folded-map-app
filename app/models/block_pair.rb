class BlockPair < ApplicationRecord

  has_many :blocks
  has_many :users, through: :blocks
  has_many :posts

end
