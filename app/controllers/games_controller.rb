class GamesController < ApplicationController
  def index
    @users = User.all
  end

  def edit
    
  end
end
