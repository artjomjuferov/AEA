class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable #:database_authenticatable,
  devise :database_authenticatable,:registerable, :recoverable, :rememberable, :trackable, :validatable

  def online?
    updated_at > 10.minutes.ago
  end
  
end
