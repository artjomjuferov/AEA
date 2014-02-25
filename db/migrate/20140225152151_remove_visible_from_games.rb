class RemoveVisibleFromGames < ActiveRecord::Migration
  def change
    remove_column :games, :visFrom, :string
    remove_column :games, :visTo, :string
  end
end
