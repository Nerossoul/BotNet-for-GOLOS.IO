require_relative 'botnet.rb'
require_relative 'golosuser.rb'
require_relative 'blacklist.rb'

botnet_commander = BotNet.new
botnet_user_names = []
botnet_commander.users.each do |user|
  botnet_user_names << user.user_name
end
loop do
  puts "Create_new_blacklist at #{Time.now}".cyan
  BlackList.create_common_black_list(botnet_user_names)
  puts "Black list created at #{Time.now}".cyan
  3600.times do |i|
    print "." if i % 5 == 0 && i != 0
    sleep(1)
  end
  puts
end
