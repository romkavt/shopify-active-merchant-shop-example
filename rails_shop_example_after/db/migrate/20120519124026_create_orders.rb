class CreateOrders < ActiveRecord::Migration
  def change
    create_table :orders do |t|
      t.decimal :id
      t.decimal :total

      t.timestamps
    end
  end
end
