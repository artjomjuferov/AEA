class AddMoneyToGames < ActiveRecord::Migration
  def change
    add_column :games, :money, :integer
  end
end
