class Chain < ActiveRecord::Base
  has_attached_file :logo, styles: { medium: "300x300>", thumb: "100x100>" },
    default_url: "https://placehold.it/300x300"
  validates_attachment_content_type :logo, content_type: /\Aimage\/.*\Z/
  has_many :stores, dependent: :destroy
  has_many :clothes, dependent: :destroy
  validates :name, presence: true
end
