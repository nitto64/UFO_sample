class Post < ApplicationRecord
  belongs_to :user
  has_one_attached :thumbnail, dependent: :destroy

  validates :title, presence: true, length: { maximum: 255 }
  validates :body, presence: true, length: { maximum: 65_535 }
end
