require 'net/http'
require 'json'

class Table
  TABLE_URL = 'http://worldcup.sfg.io/teams/group_results'
  attr_accessor :url

  def initialize
    @url = URI(TABLE_URL)
  end

  def update
    response = Net::HTTP.get(@url)
    parsed_json = JSON.parse(response)
    groups = []
    parsed_json.each do |gr|
      group = {}
      gr = gr['group']
      group[:name] = gr['letter']
      group[:teams] = []
      gr['teams'].each do |t|
        t = t['team']
        team = {}
        team[:name] = t['fifa_code']
        team[:win] = t['wins']
        team[:draw] = t['draws']
        team[:lose] = t['losses']
        team[:point] = t['points']
        team[:diff] = t['goal_differential']
        group[:teams] << team
      end
      groups << group
    end
    groups
  end
end
