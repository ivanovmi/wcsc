require 'net/http'
require 'json'
require 'pp'
class Playoff
  PLAYOFF_URL = 'http://worldcup.sfg.io/matches'
  attr_accessor :url

  def initialize
    @url = URI(PLAYOFF_URL)
  end

  def parse_match_schedule(parsed_array, match)
    m = {}
    m[:home_team] = {}
    m[:away_team] = {}
    match['home_team']['code'] == 'TBD' ? m[:home_team] = match['home_team']['team_tbd'] : m[:home_team] = match['home_team']['fifa_code']
    match['away_team']['code'] == 'TBD' ? m[:away_team] = match['away_team']['team_tbd'] : m[:away_team] = match['away_team']['fifa_code']
    parsed_array << m
  end

  def update
    response = Net::HTTP.get(@url)
    parsed_json = JSON.parse(response).last(16)
    matches = {}
    round_of_16, others = parsed_json.first(8), parsed_json.last(8)
    quarterfinal, others = others.first(4), others.last(4)
    semifinal, others = others.first(2), others.last(2)
    third_place, final = others.first(1), others.last(1)
    parsed_round_of_16 = []
    round_of_16.each do |m|
      parse_match_schedule(parsed_round_of_16, m)
    end
    parsed_quarterfinal = []
    quarterfinal.each do |m|
      parse_match_schedule(parsed_quarterfinal, m)
    end
    parsed_semifinal = []
    semifinal.each do |m|
      parse_match_schedule(parsed_semifinal, m)
    end
    parsed_tp = []
    third_place.each do |m|
      parse_match_schedule(parsed_tp, m)
    end
    parsed_final = []
    final.each do |m|
      parse_match_schedule(parsed_final, m)
    end
    matches[:r16] = parsed_round_of_16
    matches[:qf] = parsed_quarterfinal
    matches[:sf] = parsed_semifinal
    matches[:tp] = parsed_tp
    matches[:f] = parsed_final
    matches
  end
end
