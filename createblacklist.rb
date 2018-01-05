require_relative 'botnet.rb'
require_relative 'golosuser.rb'
require_relative 'blacklist.rb'

botnet_commander = BotNet.new
botnet_user_names = []
botnet_commander.users.each do |user|
  botnet_user_names << user.user_name
end
spinner = Enumerator.new do |e|
  loop do
    e.yield '|'
    e.yield '/'
    e.yield '-'
    e.yield '\\'
  end
end
loop do
  puts "Create_new_blacklist at #{Time.now}".cyan
  BlackList.create_common_black_list(botnet_user_names)
  puts "Black list created at #{Time.now}".cyan
  1.upto(14400) do |i|
    progress = "#" * (i/720) unless i < 720
    printf("\rCombined: [%-20s] %d/14400sec %s", progress, i, spinner.next)
    sleep(1)
  end
  puts
end
