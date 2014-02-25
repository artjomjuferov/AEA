class AddVisFromAndVisToToGames < ActiveRecord::Migration
  def change
    add_column :games, :visFrom, :string
    add_column :games, :visTo, :string
  end
end
