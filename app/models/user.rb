class User < ActiveRecord::Base
  devise :database_authenticatable, :recoverable, :rememberable,
    :trackable, :validatable, :registerable, :omniauthable,
    omniauth_providers: [:facebook]

  has_many :orders
  has_many :addresses, as: :addressable, dependent: :destroy
  has_one :cart
  belongs_to :current_address, class_name: 'Address'
  accepts_nested_attributes_for :addresses, allow_destroy: true

  before_create :create_customer

  validates :mobile_number, format: { with: /\(\d{3}\) \d{3}-\d{4}/ }, allow_blank: true

  def self.from_oauth(auth)
		user = find_by(provider: auth.provider, uid: auth.uid) || find_or_create_by(email: auth.email) do |user|
      user.password = Devise.friendly_token[0,20]
    end

		user.update(
			email: auth.email,
			provider: auth.provider,
      uid: auth.uid
		)

    user
  end

  def self.new_with_session(params, session)
    super.tap do |user|
      if data = session["devise.facebook_data"] && session["devise.facebook_data"]["extra"]["raw_info"]
        user.email = data["email"] if user.email.blank?
      end
    end
  end

  def current_address
    super || addresses.first
  end

  # TODO: Think about move Stripe stuffs to a proxy object
  def customer
    # TODO: Should keep caching?
    @customer ||= Stripe::Customer.retrieve(customer_id)
  end

  # TODO: Think about move Stripe stuffs to a proxy object
  def credit_cards
    customer.sources.all(object: 'card')
  end

  # TODO: Think about move Stripe stuffs to a proxy object
  def has_credit_card?
    credit_cards.any?
  end

  # TODO: Think about move Stripe stuffs to a proxy object
  def add_credit_card token_or_params
    token_or_params.merge!(object: 'card') if token_or_params.is_a?(Hash)
    customer.sources.create(source: token_or_params)
  end

  # TODO: Think about move Stripe stuffs to a proxy object
  def remove_credit_card id
    customer.sources.retrieve(id).delete()
  end

  private

    # TODO: Handle possible error on Stripe API communication
    def create_customer
      customer = Stripe::Customer.create(email: email)
      self.customer_id = customer.id
    end
end
