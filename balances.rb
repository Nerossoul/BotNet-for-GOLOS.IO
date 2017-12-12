# Check balense statistic og the botnet
require_relative 'botnet.rb'
require_relative 'golosuser.rb'
require_relative 'stringformat.rb'
golos_sum = 0.0
golos_power_sum = 0.0
gbg_sum = 0.0

botnet_commander = BotNet.new
botnet_commander.users.each do |user|
  puts user.user_name.upcase.brown
  puts '*******************************************'
  puts 'Golos: ' + user.golos.to_s
  puts 'Golos Power: ' + user.golos_power.to_s
  puts 'Golos Gold: ' + user.gbg.to_s.green
  puts 'Gests: ' + user.gests.to_s
  puts 'Voting_power: ' + user.voting_power.to_s
  puts 'Actual voting power: ' + user.actual_voting_power.to_s
  puts '*******************************************'
  golos_sum = golos_sum + user.golos.split[0].to_f
  golos_power_sum = golos_power_sum + user.golos_power
  gbg_sum = gbg_sum + user.gbg.split[0].to_f
end
puts "#{Time.now}"
puts 'Golos sum: ' + golos_sum.to_s
puts 'Golos Power sum: ' + golos_power_sum.to_s
puts 'Golos Gold sum: ' + gbg_sum.to_s.green

puts
puts "Do you want to concentrate whole gbg to #{botnet_commander.users[35].user_name}? yes/no"
answer = gets.chomp.strip.downcase
if answer == 'yes' || answer == 'y'
  puts "GBG Transfer will begin in 15 seconds"
  15.times do |i|
    sleep(0.5)
    print (i+1).to_s + " "
    sleep(0.5)
  end
  botnet_commander.gbg_concentration(botnet_commander.users[35].user_name)
elsif answer.strip.downcase == 'no'
  puts "You said \"NO\". close program"
else
  puts "You do not said \"YES\", so think you mean \"NO\". close program"
end
