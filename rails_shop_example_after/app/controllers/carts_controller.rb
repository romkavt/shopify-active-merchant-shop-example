class CartsController < ApplicationController
  include ActiveMerchant::Billing::Integrations

  def index
    @carts = Cart.all
  end

  def show
    @cart = current_cart
  end

  def new
    @cart = Cart.new
  end

  def edit
    @cart = Cart.find(params[:id])
  end

  def create
    @cart = Cart.new(params[:cart])
  end

  def update
    @cart = Cart.find(params[:id])
  end

  def destroy
    @cart = Cart.find(params[:id])
    @cart.destroy
  end

  def notify 
    notify = YandexMoney::Notification.new(request.raw_post)
    puts notify
    if notify.acknowledge ExampleStore::Application.config.yandex_money_shop_secret
      if notify.complete?
        @cart = Cart.find(notify.item_id)
        # check cart amount with notification amount
        if @cart.total_price == notify.gross
          # store complete order
          @cart.status = 'success'
          @cart.purchased_at = Time.now
          @order = Order.create(:total => notify.gross,
            :card_holder_name => notify.customer_id, # cause we don't have customer name in notification
            :order_number => notify.transaction_id)
          reset_session
        else 
          # notification amount not match with cart amount
          # set error code "100"
          notify.set_response 100 
        end
      end
    end  
    res = notify.response
    render text: res
  end

end
