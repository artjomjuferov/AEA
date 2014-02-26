class GamesController < ApplicationController
  before_filter :authenticate_user!, :except => [:show,:index]  
  after_filter :user_activity

  def index
    @users = User.where("updated_at > ?", 5.minutes.ago)
  end

  def all_bid
    @games = Game.where(status: "bid").all
  end
  
  def bid
    @game = Game.new
  end

  def create_bid
    money = params[:game][:money]
    my_id = current_user.id
    game = Game.new(from: my_id, money: money, status: "bid")
    if game.valid?
      game.save
      flash.now[:notice] = "Sucsesfully created bid #{money}"
    else
      flash.now[:notice] = game.errors.get(:from).pop
    end
    render "games/request_games"
  end

  def show_all_games
    render partial: 'games/shared/request_games_table'
  end

  def my_games
    @games = Game.all_games(current_user.id)
  end

  def req
    id = params[:id]
    money = params[:money]
    my_id = current_user.id
    game = Game.new(from: my_id, to: id, status: "request", money: money)
    if game.valid? 
      game.save
      flash.now[:notice] = "Made request game to player #{id} with #{money} $"
      PrivatePub.publish_to "/request/#{id}", id: my_id
    else  
      flash.now[:notice] = game.errors.get(:from).pop 
    end
    render "games/request_games"
  end

  def req_bid
    id = params[:id]
    money = params[:money]
    my_id = current_user.id
    # url = URI(request.referer).path.split('/').first
    game = Game.get_bid_game(id, money)
    if game
      game = Game.update(from: my_id, to: id, status: "request", money: money)
      if !game.valid? 
        flash.now[:notice] = game.errors.first 
      else  
        flash.now[:notice] = "Made request game to player #{id} with #{money} $"
        PrivatePub.publish_to "/request/#{id}", id: my_id
      end
    else
      flash.now[:notice] = "Sory doesn't exist this bid " 
    end
    render "games/request_games"
  end


  def answer
    id = params[:id]
    my_id = current_user.id
    des = params[:des]
    if des == "yes"
      Game.make_action(id, my_id) 
    else
      Game.close_game(id, my_id)
    end
    PrivatePub.publish_to "/request/#{id}", id: my_id 
    render "games/edit"
  end

  def result
    id = params[:id]
    my_id = current_user.id
    des = params[:des]  
    Game.first_won?(id, my_id, my_id) if des == 'yes'     
    Game.first_won?(my_id, id, my_id) if des == 'no' 
    PrivatePub.publish_to "/request/#{id}", id: my_id
    render "games/edit"
  end


  def close
    game =  Game.find(params[:id])
    if can_be_closed?(game, current_user.id) and game.destroy
      flash.now[:notice] = "Sucsesfully closed bid #{params[:id]}"
      PrivatePub.publish_to "/request/#{id}", id: my_id
    else
      flash.now[:notice] = "Can't closed #{params[:id]}"
    end
    @games = Game.where(status: "bid").all
    render "games/edit"
  end

  def visible 
    game = Game.find(params[:id])
    des = params[:des]
    games = Game.all_games(current_user.id)
    if game.from == current_user.id
      game.update(visFrom: des)
    else
      game.update(visTo: des)
    end
    render "games/edit"
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
