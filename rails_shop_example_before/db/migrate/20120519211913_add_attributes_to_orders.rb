class AddAttributesToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :card_holder_name, :string

    add_column :orders, :order_number, :string

  end
end
