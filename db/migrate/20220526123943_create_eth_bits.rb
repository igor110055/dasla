class CreateEthBits < ActiveRecord::Migration[6.1]
  def change
    create_table :eth_bits do |t|
      t.string :category
      t.boolean :mint, :default => true
      t.integer :mint_send_twitter, :default => 0
      t.boolean :pending, :default => false
      t.integer :pending_send_twitter, :default => 0
      t.boolean :deal, :default => false
      t.integer :deal_send_twitter, :default => 0
      t.integer :offer_send_twitter, :default => 0
      t.decimal :price
      t.string :name
      t.string :contract_address
      t.string :address
      t.string :image_url
      t.string :symbol
      t.decimal :usd_price
      t.decimal :total_price
      t.integer :quantity
      t.string :token_id
      t.string :event_timestamp
      t.string :from_username

      t.timestamps
    end
  end
end
