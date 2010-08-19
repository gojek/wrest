class UploadsController < ActionController::Base
  def create
    render :text => params[:file].read
  end
  
  def update
    render :text => params[:file].read
  end
end