# start botnet and go to rest
require_relative 'botnet.rb'
require_relative 'golosuser.rb'
require_relative 'stringformat.rb'

upvoting_upvote50_50_lunch_time = [1,20]

botnet_commander = BotNet.new
botnet_commander.users.each { |user| puts user.till_what_time_to_sleep  }
sleep(1)
puts (botnet_commander.users[0].till_what_time_to_sleep < botnet_commander.users[1].till_what_time_to_sleep)
