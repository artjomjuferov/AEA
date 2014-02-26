class Game < ActiveRecord::Base
  before_save :default_values

  validates :from, :status, :to, :money, :presence => true
  validates :from, :numericality => { :greater_than => 0 }

  validate :check_from_and_to

  def self.get_with_status(id1, id2)
    t = self.arel_table
    result = self.where(
          t[:from].eq(id1).
          and(t[:to].eq(id2)).
          or t[:from].eq(id2).
          and(t[:to].eq(id1)).
          or t[:from].eq(id1).
          and(t[:to].eq(0))
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
      self.status ||= "bid"
      self.visFrom ||= "yes"
      self.visTo ||= "yes"
      self.won ||= 0
      self.first ||= 0
    end

    def check_from_and_to
      errors.add(:password, "Can't invite yourself") if self.to == self.from
    end

end
