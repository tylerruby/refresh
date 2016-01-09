class UserSerializer
  def initialize(user)
    self.user = user
  end

  def as_json(*args)
    {
      id: user.id,
      token: token,
      credit_cards: user.credit_cards.map do |credit_card|
        {
          id: credit_card.id,
          type: credit_card.type,
          last4: credit_card.last4
        }
      end
    }
  end

  private

    attr_accessor :user

    def token
      @token ||= AuthToken.encode(user_id: user.id)
    end
end
