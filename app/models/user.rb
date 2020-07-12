class User < ApplicationRecord

  has_secure_password
  validates :email, presence: true, uniqueness: true

  belongs_to :block, optional: true
  has_many :conversations, class_name: "Conversation", foreign_key: "sender_id"
  has_many :conversations, class_name: "Conversation", foreign_key: "recipient_id"
  has_many :messages
  has_many :posts
  has_many :comments

  def block_pair
    block.block_pair
  end

  def display_name
    first_name + " " + last_name[0]
  end

end
