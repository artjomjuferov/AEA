class GamesController < ApplicationController
  def index
    @users = User.all
  end

  def edit
    @request = params[:id]
  end

end
