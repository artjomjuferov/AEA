class Game < ActiveRecord::Base
  

  def self.exist_game?(id1, id2)
    a = self.where(from: id1).where(to: id2)
    return true if !a.empty?
    b = self.where(from: id2).where(to: id1)
    return true if !b.empty?
    return false
  end

  
  def self.in_action?(id)
    a = self.where(from: id)
    return true if a.first and a.first.status == 'action'
    a = self.where(to: id)
    return true if a.first and a.first.status == 'action'
    return false 
  end

  def self.get_status(id1, id2)
    t = self.arel_table
    result = self.where(
          t[:from].eq(id1).
          and(t[:to].eq(id2)).
          or t[:from].eq(id2).
          and(t[:to].eq(id1))
    ).first
    return result.status if result
    return "none"      
  end 

  def self.all_games(id)
    t = self.arel_table
    result = self.where(
          t[:from].eq(id).
        or(t[:to].eq(id))
    )
    return result
  end

  def self.close_game(id1, id2)
    t = self.arel_table
    result = self.where(
          t[:from].eq(id1).
          and(t[:to].eq(id2)).
          or t[:from].eq(id2).
          and(t[:to].eq(id1))
    ).first
    result.destroy if result     
  end  

  def self.make_action(id1, id2)
    t = self.arel_table
    result = self.where(
          t[:from].eq(id1).
          and(t[:to].eq(id2)).
          or t[:from].eq(id2).
          and(t[:to].eq(id1))
    ).first
    if result
      result.status = "action"    
      result.save
    end
  end  

  def self.first_won?(id1, id2)
    t = self.arel_table
    result = self.where(
          t[:from].eq(id1).
          and(t[:to].eq(id2)).
          or t[:from].eq(id2).
          and(t[:to].eq(id1))
    ).first
    if result
      if result.won == id2
        result.status = "trouble"
        result.save
        return false
      elsif result.won == nil
        result.won = id1 
        result.first = id1
      else 
        result.status = "ok"
      end
      result.save
      return true
    end
  end

end
