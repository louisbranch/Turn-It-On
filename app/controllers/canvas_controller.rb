class CanvasController < ApplicationController
  def show
    redirect_to User.config[:canvas_url]
  end

  def create
    @auth = User.auth.from_signed_request(params[:signed_request])
    if @auth.authorized?
      authenticate User.identify(@auth.user)
      render :show
    else
      @options = { :scope => User.config[:scope] } 
      render :authorize
    end
  end
end
