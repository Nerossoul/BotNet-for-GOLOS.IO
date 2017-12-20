require_relative 'botnet.rb'
require_relative 'golosuser.rb'
require_relative 'stringformat.rb'

users = BotNet.read_users_data_from_file
reblogger = GolosUser.new(users[105][:user_name], users[105][:post_key], '')
users = nil
delay_time = 8*60*60/3 #8 hours delay
loop do
  min_block_number = BotNet.get_lust_max_block_number_from_file
  max_block_number = BotNet.get_max_block_number
  if (max_block_number - min_block_number) > ((FIRST_PAYOUT_PERIOD)*60*60/3)
    min_block_number = max_block_number-(FIRST_PAYOUT_PERIOD)*60*60/3
  end
  puts "Next iteration from block #{(min_block_number+1).to_s}. write this block to file".cyan.reverse_color
  BotNet.save_block_number_to_file(min_block_number)
  steps_to_max = max_block_number - delay_time - min_block_number - 1
  if steps_to_max <= 10
    puts 'wait for next few blocks born -> 120 sec...'.gray.bold
    120.times do |sec_count|
      sleep(1)
      if sec_count%3 == 0
      print sec_count/3
      else
        print "."
      end
    end
    puts
    steps_to_max = 0
  end
  steps_to_max.times do |i|
    next_block_number = min_block_number + 1 + i
    print "#{next_block_number.to_s.green.bold}" + "->#{max_block_number - delay_time}->run:" + "#{(max_block_number - delay_time - next_block_number).to_s.brown.bold}:"
    if next_block_number >= max_block_number - delay_time
      puts 'wait for next block born -> 3 sec...'.gray.bold
      sleep(3)
    else
      posts = []
      block_data = BotNet.get_block(next_block_number)
      posts = BotNet.get_posts_by_tag_from_block(GOOD_TAG_ARRAY, block_data)
      puts "--> #{posts.size.to_s.cyan.bold}" + " good posts in block ".green.bold
      if posts.size != 0
        puts '*******************Posts list********************'.brown
        puts posts
        puts '^^^^^^^^^^^^^^^^End of posts list^^^^^^^^^^^^^^^^'.brown
        posts.each do |post|
          puts "reblog next pots".green
          BotNet.get_permission_to_run_thead
          Thread::abort_on_exception = true
          Thread.new(post['author'], post['permlink']) do |author, permlink|
            reblog_data = BotNet.create_reblog_data(reblogger.user_name, author, permlink)
            BotNet.sign_transaction(reblog_data, reblogger.post_key, reblogger)
          end # end of thread
        end
      end
      puts "write block #{next_block_number} to file".cyan
      BotNet.save_block_number_to_file(next_block_number)
    end
  end
end
