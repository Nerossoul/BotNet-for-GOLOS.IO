# start playing golos loto
require_relative 'botnet.rb'
require_relative 'golosuser.rb'
require_relative 'stringformat.rb'

botnet_commander = BotNet.new
botnet_commander.launch_playing_lotos
BotNet.wait_while_all_threads_are_done
