class CreateGames < ActiveRecord::Migration
  def change
    create_table :games do |t|
      t.integer :from
      t.integer :to
      t.integer :won
      t.string :status

      t.timestamps
    end
  end
end
