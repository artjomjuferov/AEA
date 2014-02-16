class GamesController < ApplicationController
  before_filter :authenticate_user!, :except => [:show,:index]  

  def index
    @users = User.all
  end

  def edit
    g = Game.new
    @id = params[:id]
    @my_id = current_user.id
    @stage = params[:stage]
    @answer = params[:anwser]
    if g.exist_game?(@id, @my_id)
      PrivatePub.publish_to "/request/#{@my_id}",:id => @id, :stage => 'exist'
    end 
    #   PrivatePub.publish_to "/request/#{@my_id}",:id => @id, :stage => 'buzy'
    # elsif @stage = "req"
    #   p params[:anwser]
    #   @game = Game.new(@my_id, @id);
    #   PrivatePub.publish_to "/request/#{@id}",:id => @my_id, :stage => @stage
    #   PrivatePub.publish_to "/request/#{@my_id}",:id => @id, :stage => 'sent'
    # elsif @stage = "answ"
    #   if @answer == 'yes'
    #     Game.
    #     PrivatePub.publish_to "/request/#{@id}", :id => @my_id, :stage => @stage
    # end
  end

end
