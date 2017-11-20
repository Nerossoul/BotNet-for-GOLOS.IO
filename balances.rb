# Check balense statistic og the botnet
require_relative 'botnet.rb'
require_relative 'golosuser.rb'
require_relative 'stringformat.rb'
golos_sum = 0.0
golos_power_sum = 0.0
gbg_sum = 0.0

botnet_commander = BotNet.new
botnet_commander.users.each do |user|
  puts user.user_name
  puts '*******************************************'
  puts 'Golos: ' + user.golos.to_s
  puts 'Golos Power: ' + user.golos_power.to_s
  puts 'Golos Gold: ' + user.gbg.to_s
  puts 'Gests: ' + user.gests.to_s
  puts 'Voting_power: ' + user.voting_power.to_s
  puts '*******************************************'
  golos_sum = golos_sum + user.golos.split[0].to_f
  golos_power_sum = golos_power_sum + user.golos_power
  gbg_sum = gbg_sum + user.gbg.split[0].to_f
end
puts "#{Time.now}"
puts 'Golos sum: ' + golos_sum.to_s
puts 'Golos Power sum: ' + golos_power_sum.to_s
puts 'Golos Gold sum: ' + gbg_sum.to_s
