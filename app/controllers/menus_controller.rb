class MenusController < ApplicationController
  def show
    @selected_date = (params[:date] || Date.current).to_date
    @menu = Menu.find_by(
      date: @selected_date,
      region: user_region
    )
    @menu_dates = SelectMenuDates.new(Date.current).dates
    return render(:not_found, status: :unprocessable_entity) unless @menu.present?
  end

  private

    def user_region
      SelectRegion.new(current_address).region
    end
end
