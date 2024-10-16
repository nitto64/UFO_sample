class Post < ApplicationRecord
  belongs_to :user
  has_one_attached :thumbnail, dependent: :destroy
  has_many_attached :main_images, dependent: :destroy

  validates :title, presence: true, length: { maximum: 255 }
  validates :body, presence: true, length: { maximum: 65_535 }
  validates :main_images, attachment: { content_type: %r{\Aimage/(png|jpeg)\Z}, maximum: 15.megabytes, purge: true }
  validates :thumbnail, attachment: { content_type: %r{\Aimage/(png|jpeg)\Z}, maximum: 15.megabytes, purge: true }
end
