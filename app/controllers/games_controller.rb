class GamesController < ApplicationController
  before_filter :authenticate_user!, :except => [:show,:index]  

  def index
    @users = User.all
  end

  def show_all_games
    render partial: 'layouts/user_requests'
  end


  def req
    @id = params[:id]
    @my_id = current_user.id
    @status = Game.get_status(@id, @my_id) 
    if @status == "none"
      Game.create(:from => @my_id, :to => @id, :status => "request");
      PrivatePub.publish_to "/reqsuest/#{@id}", :id => @my_id 
      render "games/edit"
    else
      render "games/buzy"
    end
  end

  def answer
    @id = params[:id]
    @my_id = current_user.id
    @des = params[:des]
    p @des
    if @des == "yes"
      Game.make_action(@id, @my_id) 
    else
      Game.close_game(@id, @my_id)
    end
    PrivatePub.publish_to "/request/#{@id}", :id => @my_id 
    render "games/edit"
  end

  def result
    @id = params[:id]
    @my_id = current_user.id
    @des = params[:des]  
    Game.first_won?(@id, @my_id) if @des == 'yes'     
    Game.first_won?(@my_id, @id) if @des == 'no' 
    PrivatePub.publish_to "/request/#{@id}"
  end


  def create_bid

  end

end
