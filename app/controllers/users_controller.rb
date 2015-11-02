class UsersController < ApplicationController
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

  private

    def user_params
      params.require(:user).permit(
        addresses_attributes: [:id, :address, :city_id, :_destroy]
      )
    end
end
