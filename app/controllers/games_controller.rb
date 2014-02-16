class GamesController < ApplicationController
  before_filter :authenticate_user!, :except => [:show,:index]  

  def index
    @users = User.all
  end

  def edit
    @id = params[:id]
    @my_id = current_user.id
    @stage = params[:stage]
    @answer = params[:answer]
    p @id 
    p @stage
    p @answer 
    if Game.exist_game?(@id, @my_id) and @stage != "answ"
      PrivatePub.publish_to "/request/#{@my_id}",:id => @id, :stage => 'exist'
    elsif Game.in_action?(@id)
      PrivatePub.publish_to "/request/#{@my_id}",:id => @id, :stage => 'buzy'
    elsif @stage == "req"
      Game.create(:from => @my_id, :to => @id, :status => @stage);
      PrivatePub.publish_to "/request/#{@id}",:id => @my_id, :stage => @stage
      PrivatePub.publish_to "/request/#{@my_id}",:id => @id, :stage => 'sent'
    elsif @stage == "answ"
      Game.make_action(@id, @my_id) if @answer == 'yes'
      PrivatePub.publish_to "/request/#{@id}", :id => @my_id, :stage => @stage, :answer => @answer
      PrivatePub.publish_to "/request/#{@my_id}", :id => @id, :stage => @stage, :answer => @answer
    end
  end

end
