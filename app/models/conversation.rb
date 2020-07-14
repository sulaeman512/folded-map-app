class Conversation < ApplicationRecord

  belongs_to :sender, class_name: "User"
  belongs_to :recipient, class_name: "User"
  has_many :messages

  # Add validation that doesn't allow creation of conversation between same two users (if a conversation has already been created)

end
