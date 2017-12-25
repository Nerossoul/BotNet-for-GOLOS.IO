# start upvotin for upvote50-50 reblogs/
require_relative 'botnet.rb'
require_relative 'golosuser.rb'
require_relative 'blacklist.rb'
require_relative 'stringformat.rb'


botnet_commander = BotNet.new
botnet_user_names = []
botnet_commander.users.each do |user|
  botnet_user_names << user.user_name
end
botnet_commander.users[35].get_user_info
puts "\n\r#{botnet_commander.users[35].user_name.brown} voting power:#{botnet_commander.users[35].actual_voting_power.to_s.green} ► #{Time.now}"
puts Time.now
loop do
  actual_voting_power = botnet_commander.users[35].get_actual_voting_power(botnet_commander.users[35].voting_power, botnet_commander.users[35].last_vote_time)
  print " ► #{actual_voting_power[0].to_s.green}"
  if actual_voting_power[0] > MAX_VOTING_POWER
    puts
    puts "RUN IT NOW #{Time.now}".red
    user_reblog_history = botnet_commander.get_reblog_history('upvot50-50', FIRST_PAYOUT_PERIOD + 24)
    upvote_list = botnet_commander.create_upvote_list_from_reblog_history(user_reblog_history)
    user_reblog_history = nil
    upvote_list.each_with_index { |elem, num| puts "#{num+1}: #{elem[:pending_payout_value].to_s.green} => #{elem[:author].brown}/#{elem[:permlink].brown} "}
    botnet_commander.vote_by_each_user_for_upvote_list(upvote_list)
    BotNet.wait_while_all_threads_are_done
    upvote_list = nil
    t = Time.now
    puts "All users has been voted at #{t.hour}:#{t.min}. Waiting for next lunch".reverse_color
    GC.start
    #puts "creating_new_blacklist".green
    #BlackList.create_common_black_list(botnet_user_names)
    botnet_commander.users[35].get_user_info
    puts "\n\r#{botnet_commander.users[35].user_name.brown} voting power:#{botnet_commander.users[35].actual_voting_power.to_s.green} ► #{Time.now}"
  end
  sleep(60)
end
