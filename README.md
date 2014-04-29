# Yandex.Money with ActiveMerchant rails gem integration tutorial #

This tutorial shows how to integrate Yandex.Money online payment service 
into your rails shop application with Shopify [active_merchant](https://github.com/Shopify/active_merchant) library.

## Setting up the example 

At first check out the example shop application


```shell
$ git clone https://github.com/yandex-money/shopify-active-merchant-shop-example.git

```

When navigate to shop without Yandex.Money integration

```shell
$ cd rails_shop_example_before 
```

and set up shop example with following commands:

```shell
$ bundle install

$ rake db:migrate

$ rake db:seed
```

after all run your example

```shell
$ rails server
```

Open (http://localhost:3000/) in your browser to view the shop where your can add/edit products, add them to cart.

To buy products we must add payment service to this shop example.

## Adding Yandex.Money payment service into shop

### add 'activemerchant' gem to `Gemfile`

```ruby
gem 'activemerchant'
```

### install the gem with by `bundle install`

```shell
$ bundle install
```

### add active merchant initialization script `activemerchant.rb` to `config/initializers/` folder

```ruby
require 'active_merchant'
require 'active_merchant/billing/integrations/action_view_helper'

ActionView::Base.send(:include, ActiveMerchant::Billing::Integrations::ActionViewHelper)

# to choose 'production' or 'test' mode
ActiveMerchant::Billing::Base.integration_mode = :test # for sandbox
#ActiveMerchant::Billing::Base.integration_mode = :production # for production use
```

### add your shop secret for yandex.money to config in `application.rb`

```ruby
  config.yandex_money_shop_secret = 'YOUR_SHOP_SECRET' # replace with actial shop secret provided by Yandex.Money
```

### insert payment form to cart template `app/views/carts/show.html.erb`

```ruby
<%= payment_service_for @cart.id, "CUSTOMER_ID",
                        :amount =>  @cart.total_price,
                        :service => :yandex_money,
                        :currency => 'RUB' do |service| %>

  <% service.return_url url_for(:only_path => false, :action => 'index', :controller => 'orders') %>

  <% service.scid 12345 %>
  <% service.shopId 123 %>
  <% service.shopArticleId 1234 %>
  <% service.description  %>
  
  <%= submit_tag "Pay for your Order" %>
<% end %>
```

in this template:
 
* service.scid = 12345 - Showccase ID for your shop (provided by Yandex.Money)
* service.shopId = 123 - Your shop ID provided by Yandex.Money
* service.shopArticleId = 1234 - Article ID for your shop (provided by Yandex.Money)
* service.description - Your cart/article description

### modify `carts_controller.rb` to add payment processing

**include active merchant integration at top of the file**

```ruby
include ActiveMerchant::Billing::Integrations
```

**and add method to work with notification from Yandex.Money**

```ruby
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
```

### add notification route to `config/routes.rb`

```ruby
match '/yandexmoney/notify'=>'carts#notify'
```

### and set up CSRF protection mode that make notification works in application controller `app/controllers/application_controller.rb`

```ruby
  protect_from_forgery with: :null_session
```

## The final step

After all necessary modification in our example we can start shop again with command

```shell
$ rails server
```

and try to make test payment.

