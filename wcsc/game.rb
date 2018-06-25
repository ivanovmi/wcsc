require 'net/http'
require 'json'

require 'pp'

class Game
  CURRENT_GAME_URL = 'http://worldcup.sfg.io/matches/current'
  attr_accessor :url

  def initialize
    @url = URI(CURRENT_GAME_URL)
  end

  def update
    response = Net::HTTP.get(@url)
    parsed_json = JSON.parse(response)
    game = {}
    if parsed_json.empty? or parsed_json.nil?
      return nil
    end
    parsed_json.each do |g|
      game[:city] = g['venue']
      game[:time] = g['time']
      game[:home] = {}
      game[:home][:name] = g['home_team']['code']
      game[:home][:score] = g['home_team']['goals']
      game[:home][:stats] = {}
      game[:home][:stats][:attempts] = g['home_team_statistics']['attempts_on_goal']
      game[:home][:stats][:on_target] = g['home_team_statistics']['on_target']
      game[:home][:stats][:corners] = g['home_team_statistics']['corners']
      game[:home][:stats][:offsides] = g['home_team_statistics']['offsides']
      game[:home][:stats][:ball_possesion] = g['home_team_statistics']['ball_possession']
      game[:home][:stats][:pass_accuracy] = g['home_team_statistics']['pass_accuracy']
      game[:home][:stats][:yellow_cards] = g['home_team_statistics']['yellow_cards']
      game[:home][:stats][:red_cards] = g['home_team_statistics']['red_cards']
      game[:home][:stats][:fouls] = g['home_team_statistics']['fouls_committed']
      game[:away] = {}
      game[:away][:name] = g['away_team']['code']
      game[:away][:score] = g['away_team']['goals']
      game[:away][:stats] = {}
      game[:away][:stats][:attempts] = g['away_team_statistics']['attempts_on_goal']
      game[:away][:stats][:on_target] = g['away_team_statistics']['on_target']
      game[:away][:stats][:corners] = g['away_team_statistics']['corners']
      game[:away][:stats][:offsides] = g['away_team_statistics']['offsides']
      game[:away][:stats][:ball_possesion] = g['away_team_statistics']['ball_possession']
      game[:away][:stats][:pass_accuracy] = g['away_team_statistics']['pass_accuracy']
      game[:away][:stats][:yellow_cards] = g['away_team_statistics']['yellow_cards']
      game[:away][:stats][:red_cards] = g['away_team_statistics']['red_cards']
      game[:away][:stats][:fouls] = g['away_team_statistics']['fouls_committed']
    end
    game
  end
end
