# start botnet and go to rest
require_relative 'botnet.rb'
require_relative 'golosuser.rb'
require_relative 'stringformat.rb'

botnet_commander = BotNet.new
botnet_commander.lunch_playing_lotos
botnet_commander.whait_while_all_thread_are_done
