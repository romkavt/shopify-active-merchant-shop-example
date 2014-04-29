class ApplicationController < ActionController::Base
	helper :all
  protect_from_forgery

  def current_cart
    session[:cart_id] ||= Cart.create!.id
    @current_cart ||= Cart.find(session[:cart_id])
  end
end
