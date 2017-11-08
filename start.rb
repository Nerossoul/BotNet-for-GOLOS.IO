# запуск работы botnet
require_relative 'botnet.rb'
require_relative 'golosuser.rb'



current_path = File.dirname(__FILE__)
file_name = current_path + "/botlist.txt"

botnet_commander = BotNet.new

#users_data_array = botnet_commander.read_users_data_from_file(file_name)

#botnet_commander.create_users(users_data_array)



puts JSON.pretty_generate(botnet_commander.get_lust_post_data('pugovizza'))

