class CreateSession < ActiveRecord::Migration[5.1]
  def change
    create_table :sessions do |t|
      t.string :cookie
    end
  end
end
