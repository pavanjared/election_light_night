#!/usr/bin/env ruby

require 'httparty'
require 'nokogiri'
require 'json'
require 'pry'

# Navigate to http://www.developers.meethue.com/documentation/getting-started 
# for the following three variables
@username="h3mao-ggdyHFYjt6OSx1ZFBABoWoDsJHiTszMET2"
@ip="http://192.168.1.203"
@light_id="3"

# CONSTANT Color codes
WHITE=14956
BLUE=47125
RED=65413

# Define helper methods
def change_light(color)
  data={"on":true, "sat":254, "bri":254, "hue":color}

  response = HTTParty.put("#{@ip}/api/#{@username}/lights/#{@light_id}/state",  
                           :body => data.to_json,
                           :headers => { "Content-Type" => 'application/json'})
end

# Celebrate victory for 60 seconds
def declare_victory(color)
  loop do
    change_light(color)
    sleep(0.5)
    change_light(WHITE)
    sleep(0.5)
  end
end

def result_change_alert(color)
  change_light(WHITE)
  sleep(0.5)
  change_light(color)
  sleep(0.5)
  change_light(WHITE)
  sleep(0.5)
end

@previous_hillary_count=0
@previous_trump_count=0
@hillary_electoral_votes=0
@trump_electoral_votes=0

# Run vote checker every 60 seconds
loop do
  @previous_hillary_count=@hillary_electoral_votes
  @previous_trump_count=@trump_electoral_votes

  page = HTTParty.get('http://www.nytimes.com/elections/results/president')
  parse_page = Nokogiri::HTML(page)
  eln_object = parse_page.css('.eln-office-president').first.css('.eln-groups')
  @hillary_electoral_votes = eln_object.css('.eln-democrat').css('.eln-count').text.to_i
  @trump_electoral_votes = eln_object.css('.eln-republican').css('.eln-count').text.to_i

  # Send flash alert for a score change
  if @previous_hillary_count != @hillary_electoral_votes
    result_change_alert(BLUE)
  end  
  if @previous_trump_count != @trump_electoral_votes
    result_change_alert(RED)
  end

  if @hillary_electoral_votes >= 270
    declare_victory(BLUE)
  elsif @trump_electoral_votes >= 270
    declare_victory(RED)
  elsif @hillary_electoral_votes > @trump_electoral_votes
    change_light(BLUE)
  elsif @trump_electoral_votes > @hillary_electoral_votes
    change_light(RED)
  else
    change_light(WHITE)
  end
  
  puts "Hillary: #{@hillary_electoral_votes} Trump: #{@trump_electoral_votes}"
  sleep(10)
end
