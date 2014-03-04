class Game < ActiveRecord::Base
  after_initialize :default_values

  validates :from, :money, :status, presence: true
  validates :money, numericality: { greater_than: 0 }

  validate :exist_bid, :buzy_to, :exist_request, :from_eq_to, :buzy_from  
  validate :correct_result

  def self.get_bid_game(id, money)
    t = self.arel_table
    result = self.where(
          t[:from].eq(id).
          and(t[:status].eq('bid')).
          and(t[:money].eq(money))
    ).first
    p result
    return result      
  end

  def self.get_with_status(id1, id2)
    t = self.arel_table
    result = self.where(
          t[:from].eq(id1).
          and(t[:to].eq(id2)).
          or (t[:from].eq(id2)).
          and (t[:to].eq(id1)).
          or (t[:from].eq(id1)).
          and (t[:to].eq(0))
    ).where(t[:status].not_eq('ok')).first 
    return result      
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
    ).where(t[:status].eq('request')).first
    result.destroy if result     
  end  

  def self.make_action(id1, id2)
    t = self.arel_table
    result = self.where(
          t[:from].eq(id1).
          and(t[:to].eq(id2)).
          or t[:from].eq(id2).
          and(t[:to].eq(id1))
    ).where(t[:status].eq('request')).first
    if result
      result.status = "action"    
      result.save
    end
  end  

  def self.first_won?(id1, id2, id)
    t = self.arel_table
    result = self.where(
          t[:from].eq(id1).
          and(t[:to].eq(id2)).
          or t[:from].eq(id2).
          and(t[:to].eq(id1))
    ).where(t[:status].eq('action')).first
    if result
      if result.won == id2
        result.status = "trouble"
        result.save
        p result.errors
        return false
      elsif result.won == 0
        result.won = id1 
        result.first = id
      else 
        result.status = "ok"
      end
      result.save
      p result.errors
      return true
    end
  end

  def visible_change?(id)
    return true if self.status == "action" or self.status == "request"
    if self.from == id 
      return false if self.visFrom == "no"
    else
      return false if self.visTo == "no"
    end
    return true
  end

  def visible?(id)
    if self.from == id 
      return false if self.visFrom == "no"
    else 
      return false if self.visTo == "no"
    end
    return true
  end


  private
    
    def default_values
      self.to ||= 0
      self.visFrom ||= "yes"
      self.visTo ||= "yes"
      self.won ||= 0
      self.first ||= 0
    end

    def from_eq_to
      errors.add(:error, "invite yourself") if self.to == self.from
    end

    def buzy_from
      t = Game.arel_table
      result = Game.where(
          t[:from].eq(self.from).
          or(t[:to].eq(self.from))
      ).where(
          t[:status].eq('action')
      ).first
      errors.add(:error, "you are buzy") if result and result.won == 0
    end

    def buzy_to
      t = Game.arel_table
      result = Game.where(
          t[:from].eq(self.to).
          or(t[:to].eq(self.to))
      ).where(
          t[:status].eq('action')
      ).first
      errors.add(:error, "he is buzy") if result and result.won == 0
    end

    def exist_request 
      t = Game.arel_table
      result = Game.where(
          t[:from].eq(self.to).
          and(t[:to].eq(self.from)).
          or t[:from].eq(self.from).
          and(t[:to].eq(self.to))
      ).where(
          t[:status].eq('request')
      ).first
      errors.add(:error, "have this request") if result and self.status == "request" and self.visFrom_was == self.visFrom and self.visTo_was == self.visTo 
    end

    def exist_bid 
      t = Game.arel_table
      result = Game.where(
          t[:from].eq(self.from).
          and(t[:to].eq(0)).
          and(t[:money].eq(self.money)).
          and(t[:status].eq('bid'))
      ).first
      errors.add(:from, "have this bid") if result and self.status == "bid" and self.visFrom_was == self.visFrom 
    end

    def correct_result
      if self.won_was and self.won_was != 0 and self.won_was != self.won
        self.status = "trouble"
      end
      self.status = "ok" if self.won_was == self.won and self.won != 0
    end

end
