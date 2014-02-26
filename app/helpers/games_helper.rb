
module GamesHelper
  def make_yes_no(id, stage)
    if stage == "result"
      html = link_to "Yes", result_game_path(id, 'yes'), :remote => true 
      html += link_to "No", result_game_path(id, 'no' ),  :remote => true 
    elsif stage == "answer"
      html = link_to "Yes", answer_game_path(id, 'yes'), :remote => true 
      html += link_to "No", answer_game_path(id, 'no' ),  :remote => true 
    end
    return html.html_safe
  end

  def create_visible_switcher(id)
    game_tmp = Game.find(id)
    return "" if game_tmp and game_tmp.visible_change?(current_user.id)
    if game_tmp.from == current_user.id
      if game_tmp.visFrom == 'yes'
        html = link_to "Unvisible", visible_game_path(id,"no"), :remote => true
      else
        html = link_to "Visible", visible_game_path(id,"yes"), :remote => true
      end
    else
      if game_tmp.visTo == 'yes'
        html = link_to "Unvisible", visible_game_path(id,"no"), :remote => true
      else
        html = link_to "Visible", visible_game_path(id,"yes"), :remote => true
      end
    end
    return html.html_safe
  end

  def create_request_game(user_id, money)
    return "" if user_id == current_user.id
    path = URI(request.original_url).path.split('/')[2]
    if path == "all_bid"
      html = link_to "Request a game", request_bid_game_path(user_id, money), :class => "requestGameLink", :remote => true
    elsif path == nil
      html = link_to "Request a game", request_game_path(user_id, money), :class => "requestGameLink", :remote => true
      html += text_field_tag 'Money', 1 
    end
    return html.html_safe
  end

  def create_close_game(user_id, game_id)
    if user_id == current_user.id
      html == link_to("Close", close_game_path(game_id), :method => "delete", :remote => true) 
    end
    return html.html_safe
  end


  def create_active_game_from(game)
    return "" if game.visFrom == 'no'
    if game.status == 'request'
      html = "Waiting for #{game.to} "
      html += link_to "Close", close_game_path(game.id), :method => "delete", :remote => true
    elsif game.status == "action" and game.first != current_user.id
      html = "WON #{game.to}"
      html += make_yes_no game.to, "result" 
    end
    return html.html_safe
  end

  def create_active_game_to(game)
    return "" if game.visTo == 'no'
    if game.status == 'request'
      html = "Request from #{game.from} "
      html += make_yes_no game.from, "answer"
    elsif game.status == "action" and game.first != current_user.id
      html = "WON #{game.from}"
      html += make_yes_no game.from, "result" 
    end
    return html.html_safe
  end


  def create_active_same(game)
    return "" if game.status == "bid"
    html = ""
    if game.status == "ok"
      html = "Have a good day! Won #{game.won}"
    elsif game.status == "action" and game.first == current_user.id
      html = "Waiting for your compititor results"
    elsif game.status == "trouble" 
      html = "Ouuch!! We have send email to administration, take a while"
    end
    html += create_visible_switcher game.id 
    return html.html_safe
  end

end
