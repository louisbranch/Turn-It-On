require 'rack/oauth2'

class UsersController < ApplicationController
  before_filter :require_authentication, :only => :destroy

  rescue_from Rack::OAuth2::Client::Error, :with => :oauth2_error

  # handle Normal OAuth flow: start
  def new
    client = User.auth(callback_users_url).client
    redirect_to client.authorization_uri(
      :scope => User.config[:scope]
    )
  end

  # handle Normal OAuth flow: callback
  def create
    client = User.auth(callback_users_url).client
    client.authorization_code = params[:code]
    access_token = client.access_token!
    user = FbGraph::User.me(access_token).fetch
    authenticate User.identify(user)
    get_user_info(current_user,user)
    redirect_to canvas_url
  end

  def destroy
    unauthenticate
    redirect_to root_url
  end

  private
  
  def get_user_info(user,facebook)
    user.first_name = facebook.first_name
    user.last_name = facebook.last_name
    user.email = facebook.email
    user.save
  end

  def oauth2_error(e)
    flash[:error] = {
      :title => e.response[:error][:type],
      :message => e.response[:error][:message]
    }
    redirect_to canvas_url
  end
end
