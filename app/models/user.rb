class User < ApplicationRecord

  belongs_to :block
  has_many :conversations, class_name: "Conversation", foreign_key: "sender_id"
  has_many :conversations, class_name: "Conversation", foreign_key: "recipient_id"
  has_many :messages
  has_many :posts
  has_many :comments

  def block_pair
    block.block_pair
  end

end
