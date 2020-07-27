class Post < ApplicationRecord

  belongs_to :block_pair
  belongs_to :user
  has_many :comments, dependent: :destroy

end
