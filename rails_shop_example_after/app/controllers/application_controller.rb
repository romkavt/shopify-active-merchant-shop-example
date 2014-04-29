class ApplicationController < ActionController::Base
    helper :all
  protect_from_forgery with: :null_session

  def current_cart
    session[:cart_id] ||= Cart.create!.id
    @current_cart ||= Cart.find(session[:cart_id])
  end
end
