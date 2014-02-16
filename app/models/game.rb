class Game < ActiveRecord::Base
  attr_accessor :won
  
  def self.exist_game?(id1, id2)
    a = self.where(from: id1).where(to: id2)
    return true if !a.empty?
    b = self.where(from: id2).where(to: id1)
    return true if !b.empty?
    return false
  end

  def self.buzy?(id)
    a = self.where(from: id)
    return true if a.first and a.first.status == 'buzy'
    a = self.where(to: id)
    return true if a.first and a.first.status == 'buzy'
    return false 
  end

  def self.all_games(id)
    t = self.arel_table
    result = self.where(
          t[:from].eq(id).
        or(t[:to].eq(id))
    )
    return result
  end

  def agree_start()
  end

  def disagree_start()
  end

end
