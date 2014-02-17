class AddFirstAndVisibleToGames < ActiveRecord::Migration
  def change
    add_column :games, :first, :integer
    add_column :games, :visible, :string
  end
end
