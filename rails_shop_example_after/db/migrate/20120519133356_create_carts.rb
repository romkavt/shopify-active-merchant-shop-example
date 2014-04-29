class CreateCarts < ActiveRecord::Migration
  def change
    create_table :carts do |t|
      t.datetime :purchased_at

      t.timestamps
    end
  end
end
