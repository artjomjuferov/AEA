
module GamesHelper
  def make_yes_no(game, stage)
    if stage == "result"
      html = link_to "Yes", result_game_path(game.id, 'yes'), :remote => true 
      html += link_to "No", result_game_path(game.id, 'no' ),  :remote => true 
    elsif stage == "answer"
      html = link_to "Yes", answer_game_path(game.id, 'yes'), :remote => true 
      html += link_to "No", answer_game_path(game.id, 'no' ),  :remote => true 
    end
    html.html_safe if html
  end

  def create_visible_switcher(game)
    if game.from == current_user.id
      if game.visFrom == 'yes'
        html = link_to "Unvisible", visible_game_path(game.id,"no"), :remote => true
      else
        html = link_to "Visible", visible_game_path(game.id,"yes"), :remote => true
      end
    else
      if game.visTo == 'yes'
        html = link_to "Unvisible", visible_game_path(game.id,"no"), :remote => true
      else
        html = link_to "Visible", visible_game_path(game.id,"yes"), :remote => true
      end
    end
    html.html_safe if html
  end

  def create_request_game(user_id, money)
    return "" if user_id == current_user.id
    path = URI(request.original_url).path.split('/')[2]
    if path == "all_bid"
      html = link_to "Request a game", request_bid_game_path(user_id, money), :class => "requestGameLink", :remote => true
    elsif path == nil
      html = link_to "Request a game", request_game_path(user_id, money), :class => "requestGameLink", :remote => true
      html += text_field_tag "requestGameInput#{user_id}", 1 , :class => "requestGameInput" 
    end
    html.html_safe if html
  end

  def create_close_game(user_id, game)
    if user_id == current_user.id
      html = link_to "Close", close_game_path(game.id), :method => "delete", :remote => true 
    end
    html.html_safe if html
  end


  def create_active_game_from(game)
    if game.status == 'request'
      html = "Waiting for #{game.to} "
      html += create_close_game(current_user.id, game)
    elsif game.status == "action" and game.first != current_user.id
      html = "WON #{game.to}"
      html += make_yes_no game, "result" 
    end
    html.html_safe if html
  end

  def create_active_game_to(game)
    if game.status == 'request'
      html = "Request from #{game.from} "
      html += make_yes_no game, "answer"
    elsif game.status == "action" and game.first != current_user.id
      html = "WON #{game.from}"
      html += make_yes_no game, "result" 
    end
    html.html_safe if html
  end


  def create_active_same(game)
    if game.status == "ok"
      html = "Have a good day! Won #{game.won}"
    elsif game.status == "action" and game.first == current_user.id
      html = "Waiting for your compititor results"
    elsif game.status == "trouble" 
      html = "Ouuch!! We have send email to administration, take a while"
    elsif game.status == "bid"
      html = "You have created bid #{game.money}"
      html += create_close_game(current_user.id, game)
    end
    html += create_visible_switcher game if html
    html.html_safe if html
  end

end
