class UsersController < ApplicationController
  before_action :authenticate_api!

  def edit
    @user = current_user
  end

  def update
    @user = current_user
    if @user.update(user_params)
      flash[:success] = "Profile updated with success!"
      redirect_to root_path
    else
      flash[:danger] = current_user.errors.full_messages.join(', ')
      render :edit
    end
  end

  def add_credit_card
    respond_to do |format|
      format.json do
        begin
          credit_card = current_user.add_credit_card params[:credit_card]
          message = 'Card added!'
          partial_html = render_to_string(partial: 'pages/account/credit_cards', locals: { message: message})
          render json: {
            message: message,
            html: partial_html,
            credit_card: {
              id: credit_card.id,
              type: credit_card.type,
              last4: credit_card.last4
            }
          }
        rescue Stripe::CardError => e
          @credit_card = CreditCard.new params[:credit_card]
          @credit_card.errors.add(:base, e.message)
          partial_html = render_to_string(partial: 'pages/account/credit_cards', locals: { message: e.message })
          render json: { message: e.message, html: partial_html }, status: :unprocessable_entity
        end
      end
    end
  end

  def remove_credit_card
    current_user.remove_credit_card params[:credit_card_id]
    respond_to do |format|
      format.json { head :ok }
      format.html do
        flash[:success] = 'Credit card removed.'
        redirect_to :back
      end
    end
  end

  def new_token
    render json: UserSerializer.new(current_user)
  end

  private

    def user_params
      params.require(:user).permit(
        addresses_attributes: [:id, :address, :city_id, :_destroy]
      )
    end
end
