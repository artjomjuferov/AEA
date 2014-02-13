class Games < ActiveRecord::Base
  attr_accessor :won, :status
  
  def inizialize(to, from)
    self.to = to;
    self.from = from;
    self.status = 'req';
  end
  
  def exist_game?(id_1, id_2)
    a = self.where(from: id_1).where(to: id_2)
    return true if !a.empty?
    b = self.where(from: id_2).where(to: id_1)
    return true if !b.empty?
    return false
  end

  def buzy?(id)
    a = self.where(from: id)
    return true if a.status == 'buzy'
    a = self.where(to: id)
    return true if a.status == 'buzy'
    return false 
  end

  def agree_start()
  end

  def disagree_start()
  end

end
