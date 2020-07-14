class User < ApplicationRecord

  has_secure_password
  validates :email, presence: true, uniqueness: true

  belongs_to :block, optional: true
  has_many :messages
  has_many :posts
  has_many :comments

  # belongs_to block_pair w/ custom method
  def block_pair
    block.block_pair
  end

  # has_many conversations w/ custom method
  def conversations
    Conversation.where("sender_id = ? OR recipient_id = ?", id, id)
  end

  def display_name
    first_name + " " + last_name[0]
  end

end
