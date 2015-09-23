class Cloth < ActiveRecord::Base
  monetize :price_cents
  enum gender: %w(male female unisex)

  has_attached_file :image, styles: { medium: "300x300>", thumb: "100x100>" },
    default_url: "https://placehold.it/1000x600"
  validates_attachment_content_type :image, content_type: /\Aimage\/.*\Z/

  belongs_to :chain
  has_many :cloth_variants
  validates :name, :chain, presence: true

  def colors=(values)
    values = values.split(',') if values.is_a? String
    write_attribute(:colors, values.map(&:strip))
  end

  attr_accessor :cloth_variants_configuration

  after_create do
    next unless cloth_variants_configuration.present?
    JSON.parse(cloth_variants_configuration).each do |size, colors|
      colors.each do |color|
        ClothVariant.create!(cloth: self, size: size, color: color)
      end
    end
  end

  rails_admin do
    edit do
      field :name
      field :price
      field :gender do
        enum Cloth.genders
      end
      field :cloth_variants_configuration do
        help <<-EOS
          Required - Configure the cloth variants that will be created.\n
          Please use the following format, including quotes:\n
          { \"L\": [\"red\", \"blue\"], \"M\": [\"blue\", \"green\"] }
        EOS
        required true
        visible do
          bindings[:object].new_record?
        end
      end
      field :image
      field :chain
    end

    list do
      field :name

      field :price do
        pretty_value do
          value.format
        end
      end

      field :colors
      field :image
      field :chain
    end
  end
end
