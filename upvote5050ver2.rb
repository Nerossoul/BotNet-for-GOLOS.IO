# start upvotin for upvote50-50 reblogs/
require_relative 'botnet.rb'
require_relative 'golosuser.rb'
require_relative 'stringformat.rb'

upvoting_upvote50_50_lunch_time = [9,0]

botnet_commander = BotNet.new
puts Time.now
loop do
  botnet_commander.users[35].get_user_info
  puts "\n\r#{botnet_commander.users[35].user_name.brown} voting power:#{botnet_commander.users[35].actual_voting_power.to_s.green} --> #{Time.now}"
    if botnet_commander.users[35].actual_voting_power > 99.5
      puts
      puts "RUN IT NOW #{Time.now}".red
      user_reblog_history = botnet_commander.get_reblog_history('upvote50-50', FIRST_PAYOUT_PERIOD + 24)
      upvote_list = botnet_commander.create_upvote_list_from_reblog_history(user_reblog_history)
      upvote_list.each_with_index { |elem, num| puts "#{num+1}: #{elem[:pending_payout_value].to_s.green} => #{elem[:author].brown}/#{elem[:permlink].brown} "}
      botnet_commander.vote_by_each_user_for_upvote_list(upvote_list)
      botnet_commander.wait_while_all_threads_are_done
      t = Time.now
      puts "All users has been voted at #{t.hour}:#{t.min}. Waiting for next lunch".reverse_color
    end
  10.times do #minutes waiting
    sleep(59)
    print "." # each minute print dot
  end
end
