class DriversController < ApplicationController
  def new
    @driver = Driver.new
  end

  def create
    @driver = Driver.new(params[:contact])
    @driver.request = request
    if @driver.deliver
      flash.now[:notice] = 'Thank you for your application. We will be in touch soon!'
    else
      flash.now[:error] = 'Cannot submit application.'
      render :new
    end
  end
end