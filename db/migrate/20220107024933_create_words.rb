class CreateWords < ActiveRecord::Migration[6.1]
  def change
    create_table :words do |t|
      t.string :name, uniq:true
      t.integer :num, default: 0
    end

  end
end
