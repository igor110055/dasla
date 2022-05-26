class CreateEthBits < ActiveRecord::Migration[6.1]
  def change
    create_table :eth_bits do |t|
      t.string :acount
      t.bollean :mint
      t.bollean :pending
      t.boolean :deal
      t.decimal :price
      t.string :token_id

      t.timestamps
    end
  end
end
