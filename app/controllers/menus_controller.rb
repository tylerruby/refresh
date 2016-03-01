class MenusController < ApplicationController
  def show
    unless current_address.present?
      return respond_to do |format|
        format.json do
          render json: {
            message: "You should choose a current address first."
          }, status: :unprocessable_entity
        end

        format.html do
          flash[:alert] = "You should choose a current address first."
          redirect_to root_path
        end
      end
    end

    @menu_dates    = SelectMenuDates.new(Date.current).dates
    @selected_date = (params[:date] || @menu_dates.first).to_date
    @menu          = Menu.find_by(date: @selected_date, region: current_region)

    return render(:not_found, status: :unprocessable_entity) unless @menu.present?
  end
end
