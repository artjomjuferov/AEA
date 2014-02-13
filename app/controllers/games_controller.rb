class GamesController < ApplicationController
  before_filter :authenticate_user!, :except => [:show,:index]  

  def index
    @users = User.all
  end

  def edit
    @id = params[:id]
    @stage = params[:stage]
    if @stage = "req"
      p params[:anwser]
      PrivatePub.publish_to "/request/#{@id}",:id => current_user.id, :stage => @stage
      PrivatePub.publish_to "/request/#{current_user.id}",:id => @id, :stage => 'sent'
    elsif @stage = "answ"
      @answer = params[:anwser]
      PrivatePub.publish_to "/request/#{@id}", :id => current_user.id, :stage => @stage
    end
  end

end
