# start botnet and go to rest
require_relative 'botnet.rb'
require_relative 'golosuser.rb'
require_relative 'stringformat.rb'

upvoting_upvote50_50_lunch_time = [9,0]

botnet_commander = BotNet.new
puts Time.now
loop do
  t = Time.now
  print "."
    if (t.hour == upvoting_upvote50_50_lunch_time[0] and t.min == upvoting_upvote50_50_lunch_time[1])
      puts
      puts "RUN IT NOW".red
      user_reblog_history = botnet_commander.get_reblog_history('upvote50-50', 48)
      upvote_list = botnet_commander.create_upvote_list_from_reblog_history(user_reblog_history)
      upvote_list.each_with_index { |elem, num| puts "#{num+1}: #{elem[:pending_payout_value].to_s.green} => #{elem[:author].brown}/#{elem[:permlink].brown} "}
      botnet_commander.vote_by_each_user_for_upvote_list(upvote_list)
        sleep(65)
        t = Time.now
        puts "All users begin voted at #{t.hour}:#{t.min}. Waiting for next lunch".reverse_color
    end
  sleep(59)
end
