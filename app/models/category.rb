class Category < ActiveRecord::Base
  has_many :clothes

  validates :name, presence: true
  validate :assert_at_least_one_gender

  # TODO: Find a way to show this on admin
  def gender
    case
    when male && female then :unisex
    when male then :male
    when female then :female
    end
  end

  private

    def assert_at_least_one_gender
      unless male || female
        errors.add(:male, :at_least_one_gender)
        errors.add(:female, :at_least_one_gender)
      end
    end
end
