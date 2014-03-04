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
      flash.now[:notice] = game.errors.get(:error).pop
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
      p game.errors
      flash.now[:notice] = game.errors.get(:error).pop 
    end
    render "games/request_games"
  end

  def req_bid
    id = params[:id]
    money = params[:money]
    my_id = current_user.id
    game = Game.get_bid_game(id, money)
    if game
      game.update(from: my_id, to: id, status: "request", money: money)
      if !game.valid? 
        flash.now[:notice] = game.errors.get(:error).first 
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
    game_id = params[:id]
    my_id = current_user.id
    des = params[:des]
    game = Game.find(params[:id])
    game.from == my_id ? id = game.to : id = game.from
    if des == "yes"
      game.update(status: "action") 
      if !game.valid?
        flash.now[:notice] = game.errors.get(:from).first 
      end 
    else
      game.update(status: "closed") 
      if !game.valid?
        flash.now[:notice] = game.errors.get(:from).first 
      end
    end
    PrivatePub.publish_to "/request/#{id}", id: my_id 
    render "games/request_games"
  end

  def result
    game_id = params[:id]
    my_id = current_user.id
    des = params[:des]
    game = Game.find(params[:id])
    game.from == my_id ? id = game.to : id = game.from
    # p my_id,id
    if des == "yes"
      game.update(won: id, first: my_id)  
    else
      game.update(won: my_id, first: my_id) 
    end  
    if !game.valid?
      p game.errors
      flash.now[:notice] = game.errors.get(:error).first 
    end
    PrivatePub.publish_to "/request/#{id}", id: my_id
    render "games/request_games"
  end


  def close
    game =  Game.find(params[:id])
    my_id = current_user
    game.from == my_id ? id = game.to : id = game.from
    if can_be_closed?(game, current_user.id) and game.destroy
      flash.now[:notice] = "Sucsesfully closed bid #{params[:id]}"
      PrivatePub.publish_to "/request/#{id}", id: my_id
    else
      flash.now[:notice] = "Can't closed #{params[:id]}"
    end
    @games = Game.where(status: "bid").all
    render "games/request_games"
  end

  def visible 
    game = Game.find(params[:id])
    des = params[:des]
    if game.from == current_user.id
      game.update(visFrom: des)
      p game.errors.messages
    else
      p game.errors.messages
      game.update(visTo: des)
    end
    render "games/request_games"
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
