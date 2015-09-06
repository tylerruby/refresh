class Store < ActiveRecord::Base
  extend FriendlyId
  friendly_id :slug_candidates, use: :slugged

  has_attached_file :image, styles: { medium: "300x300>", thumb: "100x100>" },
    default_url: "https://placehold.it/1000x600"
  validates_attachment_content_type :image, content_type: /\Aimage\/.*\Z/

  RADIUS = 10 # miles
  geocoded_by :full_address
  after_validation :geocode, if: -> { address.present? and address_changed? }

  belongs_to :chain
  has_many :clothes, through: :chain
  validates :address, :city, :state, :chain, presence: true
  scope :by_city, -> (city) { where('lower(city) = ?', city.downcase) }
  scope :order_by_distance, -> (location) { 
    select("#{table_name}.*")
    .select("(#{distance_from_sql(location)}) as distance")
    .order('distance')
  }

  def name
    super.present? ? super : chain.try(:name)
  end

  def full_address
    [address, city, state].join(', ')
  end

  def available_for_delivery?
    distance_from_user <= RADIUS
  end

  def slug_candidates
    [
      :name,
      [:name, :city],
      [:name, :city, :state],
      [:name, :city, :state, :id]
    ]
  end

  rails_admin do
    edit do
      field :name do
        help "Optional - Will override the chain's name"
      end

      field :address
      field :city
      field :state
      field :image
      field :chain
    end

    list do
      field :name
      field :chain
      field :full_address
      field :image
    end
  end

  private

  def distance_from_user
    distance
  rescue NameError => e
    # distance is a method defined when making a query with distance
    # calculation, so it may not be defined if the model was retrived
    # in another way. In this case, we default to an infinite distance.
    Float::INFINITY
  end
end
