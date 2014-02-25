class GamesController < ApplicationController
  before_filter :authenticate_user!, :except => [:show,:index]  
  after_filter :user_activity

  def index
    @users = User.where("updated_at > ?", 5.minutes.ago)
  end

  def all_bid
    @games = Game.where(status: "bid").all
  end

  def show_all_games
    render partial: 'layouts/user_requests'
  end

  def my_games
    @games = Game.all_games(params[:id])
  end

  # why doesn't publish here is the question
  def req
    @id = params[:id]
    @my_id = current_user.id
    @status = Game.get_status(@id, @my_id) 
    PrivatePub.publish_to "/reqsuest/new", id: @my_id
    if @status == "none" or @status == "ok"   
      Game.create(from: @my_id, to: @id, status: "request")
      PrivatePub.publish_to "/request/#{@id}", id: @my_id
      render "games/edit"
    else
      render "games/buzy"
    end
  end

  def close
    @game =  Game.find(params[:id])
    if can_be_closed?(@game, current_user.id) and @game.destroy
      flash.now[:notice] = "Sucsesfully closed bid #{params[:id]}"
      PrivatePub.publish_to "/request/#{@id}", id: @my_id
    else
      flash.now[:notice] = "Can't closed #{params[:id]}"
    end
    @games = Game.where(status: "bid").all
    render "games/bid_edit"
  end

  def visible 
    Game.find(params[:id]).update(visible: params[:des])
    p "sd"
    render "games/edit"
  end

  def answer
    @id = params[:id]
    @my_id = current_user.id
    @des = params[:des]
    if @des == "yes"
      Game.make_action(@id, @my_id) 
    else
      Game.close_game(@id, @my_id)
    end
    PrivatePub.publish_to "/request/#{@id}", id: @my_id 
    render "games/edit"
  end

  def result
    @id = params[:id]
    @my_id = current_user.id
    @des = params[:des]  
    Game.first_won?(@id, @my_id) if @des == 'yes'     
    Game.first_won?(@my_id, @id) if @des == 'no' 
    PrivatePub.publish_to "/request/#{@id}", id: @my_id
    render "games/edit"
  end


  def bid
    @game = Game.new
  end

  def create_bid
    @money = params[:game][:money]
    @my_id = current_user.id
    if Game.create(from: @my_id, to: 0, status: "bid", money: @money)
      flash.now[:notice] = "Sucsesfully created bid( #{@money} )"
    else
      flash.now[:notice] = "Can't create bid( #{@money} )"
    end
    @game = Game.new
    respond_to do |format|
      format.html { render "bid" }
    end
  end

  private
    def user_activity
      current_user.try :touch
    end

    def can_be_closed?(game, user_id)
      return false if game.status == "trouble"  or game.status == "action" or game.status == "result" 
      return true if game.from == user_id and game.status == "bid"
      return true if game.from == user_id or game.to == user_id
      return false 
    end

end
