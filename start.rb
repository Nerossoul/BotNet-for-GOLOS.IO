# start botnet and go to rest
require_relative 'botnet.rb'
require_relative 'golosuser.rb'
require_relative 'stringformat.rb'

bots = BotNet.new

puts bots.users[0].voting_power
puts bots.users[0].future_voting_power
bots.users[0].future_voting_power = bots.users[0].future_voting_power - ((bots.users[0].future_voting_power/100*0.5).round(2))
puts bots.users[0].voting_power
puts bots.users[0].future_voting_power
