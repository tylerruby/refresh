class User < ActiveRecord::Base
  devise :database_authenticatable, :recoverable, :rememberable,
    :trackable, :validatable, :registerable, :omniauthable,
    omniauth_providers: [:facebook]

  has_many :orders
  has_many :addresses, as: :addressable, dependent: :destroy
  belongs_to :current_address, class_name: 'Address'
  accepts_nested_attributes_for :addresses, allow_destroy: true

  before_create :create_customer

  def self.from_omniauth(auth)
    where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
      user.email = auth.info.email
      user.password = Devise.friendly_token[0,20]
    end
  end

	def self.from_oauth(oauth)
		data = oauth.get_data

		user = find_by(provider: oauth.provider, uid: data[:id]) || find_or_create_by(email: data[:email]) do |u|
			u.password =  SecureRandom.hex
		end

    # first_name, last_name = [data[:first_name], data[:last_name]]
		user.update(
			# display_name: [first_name, last_name].join(' '),
			email: data[:email],
			provider: oauth.provider,
      uid: data[:id]
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
