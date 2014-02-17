
module GamesHelper
  def make_yes_no(id, stage)
    if stage == "result"
      html = link_to "Yes", result_game_path( id, 'yes'), :remote => true 
      html += link_to "No", result_game_path( id, 'no' ),  :remote => true 
    elsif stage == "answer"
      html = link_to "Yes", answer_game_path( id, 'yes'), :remote => true 
      html += link_to "No", answer_game_path( id, 'no' ),  :remote => true 
    end
    return html
  end
end
