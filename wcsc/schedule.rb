require 'net/http'
require 'json'

class Schedule
  SCHEDULE_URL = 'http://worldcup.sfg.io/matches/today'
  attr_accessor :url

  def initialize
    @url = URI(SCHEDULE_URL)
  end

  def update
    response = Net::HTTP.get(@url)
    parsed_json = JSON.parse(response)
    matches = []
    parsed_json.each do |m|
      match = {}
      match[:city] = m['venue']
      match[:status] = m['status']
      match[:home_team] = {}
      match[:home_team][:name] = m['home_team']['code']
      match[:home_team][:goals] = m['home_team']['goals']
      match[:away_team] = {}
      match[:away_team][:name] = m['away_team']['code']
      match[:away_team][:goals] = m['away_team']['goals']
      matches << match
    end
    matches
  end
end
