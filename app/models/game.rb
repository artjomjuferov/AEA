class Game < ActiveRecord::Base
  before_save :default_values

  validates :from, :money, :status, presence: true
  validates :money, numericality: { greater_than: 0 }

  validate :duplicate, :exist_bid, :buzy_to, :exist_request, :from_eq_to, :buzy_from  
  
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
        return false
      elsif result.won == 0
        result.won = id1 
        result.first = id
      else 
        result.status = "ok"
      end
      result.save
      return true
    end
  end

  def visible_change?(id)
    return true if self.status != "bid" and self.status != "ok" and self.status != "trouble"
    if self.from == id 
      return false if self.visFrom == "No"
    else
      return false if self.visTo == "No"
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
      errors.add(:from, "invsite yourself") if self.to == self.from
    end

    def duplicate
      errors.add(:from, "invites yourself") if self.status_was == self.status
    end

    def buzy_from
      t = Game.arel_table
      result = Game.where(
          t[:from].eq(self.from).
          or(t[:to].eq(self.from))
      ).where(
          t[:status].eq('action')
      ).first
      errors.add(:from, "already have game") if result
    end

    def buzy_to
      t = Game.arel_table
      result = Game.where(
          t[:from].eq(self.to).
          or(t[:to].eq(self.to))
      ).where(
          t[:status].eq('action')
      ).first
      errors.add(:to, "is buzy") if result
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
      errors.add(:from, "have this request") if result and self.status != "action"
    end

    def exist_bid 
      t = Game.arel_table
      result = Game.where(
          t[:from].eq(self.from).
          and(t[:to].eq(0)).
          and(t[:money].eq(self.money)).
          and(t[:status].eq('bid'))
      ).first
      errors.add(:from, "have this bid") if result
    end

end
