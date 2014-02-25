
module GamesHelper
  def make_yes_no(id, stage)
    if stage == "result"
      html = link_to "Yes", result_game_path(id, 'yes'), :remote => true 
      html += link_to "No", result_game_path(id, 'no' ),  :remote => true 
    elsif stage == "answer"
      html = link_to "Yes", answer_game_path(id, 'yes'), :remote => true 
      html += link_to "No", answer_game_path(id, 'no' ),  :remote => true 
    end
    return html
  end

  def make_visible(id)
    game_tmp = Game.find(id)
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
    return html
  end

  def make_actions(user_id, game_id)
    html = link_to "Request a game", request_game_path(user_id), :remote => true
    html += link_to "Close", close_game_path(game_id), :method => "delete", :remote => true 

    return html 
  end
end
