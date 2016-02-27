class GuestUser
  def initialize(session)
    self.session = session
  end

  def persisted?
    false
  end

  def current_address
    @current_address ||= Address.find_by(id: session[:address_id])
  end

  def cart
    @cart ||= Cart.find_by(id: session[:cart_id])
  end

  def update!(attributes)
    session[:address_id] = attributes[:current_address].id if attributes[:current_address]
    session[:cart_id] = attributes[:cart].id if attributes[:cart]
  end

  private

    attr_accessor :session
end
