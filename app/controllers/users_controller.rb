class UsersController < ApplicationController
  before_action :authenticate_api!, except: [:set_current_address]

  def edit
    @user = current_user
  end

  def update
    @user = current_user
    if @user.update(user_params)
      flash[:success] = "Profile updated with success!"
      redirect_to account_path
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
          render_credit_card_error(e.message)
        rescue
          render_credit_card_error("Something went wrong.")
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

  def set_current_address
    current_user.update!(current_address: new_address)

    respond_to do |format|
      format.json do
        render json: { city: new_address.city.name.parameterize }
      end

      format.html do
        redirect_to menu_path(city: city.parameterize)
      end
    end
  end

  private

    def user_params
      params.require(:user).permit(
        :avatar,
        :email,
        addresses_attributes: [:id, :address, :city_id, :_destroy]
      )
    end

    def render_credit_card_error(message)
      partial_html = render_to_string(partial: 'pages/account/credit_cards', locals: { message: message })
      render json: { message: message, html: partial_html }, status: :unprocessable_entity
    end

    def city
      @city ||= fetched_address.city
    end

    def fetched_address
      @fetched_address ||= FetchAddress.new(params[:address])
    end

    def new_address
      scope = current_user.persisted? && current_user.addresses || Address
      @new_address ||= scope.find_or_create_by(
        address: fetched_address.formatted_address,
        city: City.find_or_create_by(name: city),
        latitude: fetched_address.latitude,
        longitude: fetched_address.longitude
      )
    end
end
