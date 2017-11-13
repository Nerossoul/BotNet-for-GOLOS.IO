# start botnet and go to rest
require_relative 'botnet.rb'
require_relative 'golosuser.rb'
require_relative 'stringformat.rb'

botnet_commander = BotNet.new
puts JSON.pretty_generate(botnet_commander.get_repost_history('nerossoul', 5))

#user_vote_history = botnet_commander.get_user_vote_history('sept', 4)
#botnet_commander.folow_vote_history(user_vote_history)
#botnet_commander.whait_while_all_thread_are_done
