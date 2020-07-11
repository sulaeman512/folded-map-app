class User < ApplicationRecord

  belongs_to :block
  has_many :conversations
  has_many :messages
  has_many :posts
  has_many :comments

  def block_pair
    block.block_pair
  end

end
