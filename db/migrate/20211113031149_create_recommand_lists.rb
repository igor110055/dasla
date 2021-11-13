class CreateRecommandLists < ActiveRecord::Migration[6.1]
  def change
    create_table :recommand_lists do |t|
      t.string :domain, uniq:true
      t.boolean :is_reg, default: false
      t.boolean :is_recommand, default: false

      t.timestamps
    end
  end
end
