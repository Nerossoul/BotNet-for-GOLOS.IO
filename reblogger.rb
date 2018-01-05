require_relative 'botnet.rb'
require_relative 'golosuser.rb'
require_relative 'stringformat.rb'

arrow = Enumerator.new do |e|
  loop do
    e.yield '    ----------> '
    e.yield '     ---------- '
    e.yield '      --------- '
    e.yield '       -------- '
    e.yield '   >    ------- '
    e.yield '   ->    ------ '
    e.yield '   -->    ----- '
    e.yield '   --->    ---- '
    e.yield '   ---->    --- '
    e.yield '   ----->    -- '
    e.yield '   ------>    - '
    e.yield '   ------->     '
    e.yield '   -------->    '
    e.yield '   --------->   '
    e.yield '   ---------->  '
  end
end

users = BotNet.read_users_data_from_file
reblogger = GolosUser.new(users[105][:user_name], users[105][:post_key], '')
users = nil
delay_time = 8*60*60/3 #8 hours delay
loop do
  puts
  min_block_number = BotNet.get_lust_max_block_number_from_file
  # puts "in file block is #{min_block_number}"
  max_block_number = BotNet.get_max_block_number
  # puts "BlockChain max blok is #{max_block_number}"
  if (max_block_number - min_block_number) > ((FIRST_PAYOUT_PERIOD)*60*60/3)
    min_block_number = max_block_number-(FIRST_PAYOUT_PERIOD)*60*60/3
    # puts "#{min_block_number} = #{max_block_number}-#{(FIRST_PAYOUT_PERIOD)*60*60/3}"
  end
  # puts "Next block #{(min_block_number+1).to_s}-->#{Time.now} ".cyan.reverse_color
  BotNet.save_block_number_to_file(min_block_number)
  steps_to_max = max_block_number - delay_time - min_block_number - 1
  # puts "#{steps_to_max} = #{max_block_number} - #{delay_time} - #{min_block_number} - 1"
  if steps_to_max <= 39
    puts
    40.times do |sec_count|
      #sleep(3)
      print "#{arrow.next}".blue.bold +
            " Born #{sec_count + 1} block  \r".cyan
      3.times do
        sleep(1)
        print "#{arrow.next}".blue.bold + "\r"
      end
    end
    puts
    steps_to_max = 0
  end
  steps_to_max.times do |i|
    next_block_number = min_block_number + 1 + i
    print "#{i+1}/#{steps_to_max} --> #{next_block_number.to_s.green.bold}" + "->#{max_block_number - delay_time}->run:" + "#{(max_block_number - delay_time - next_block_number).to_s.brown.bold}:"
    if next_block_number >= max_block_number - delay_time
      puts 'wait for next block born -> 3 sec...'.gray.bold
      sleep(3)
    else
      posts = []
      block_data = BotNet.get_block(next_block_number)
      posts = BotNet.get_posts_by_tag_from_block(GOOD_TAG_ARRAY, block_data)
      print " --> #{posts.size.to_s.cyan.bold}" + " good posts in block".green.bold
      if i+1 == steps_to_max
        print " DONE".cyan.bold
      else
        print " \r"
      end
      if posts.size != 0
        #puts
        #puts '*******************Posts list********************'.brown
        #puts posts
        #puts '^^^^^^^^^^^^^^^^End of posts list^^^^^^^^^^^^^^^^'.brown
        posts.each do |post|
          #puts "reblog next pots".green
          BotNet.get_permission_to_run_thead
          Thread::abort_on_exception = true
          Thread.new(post['author'], post['permlink']) do |author, permlink|
            if BAD_AUTHORS_APVOT5050.include? author
              puts "BAD_AUTHORS_APVOT5050 is include #{author}".red
            else
              reblog_data = BotNet.create_reblog_data(reblogger.user_name, author, permlink)
              BotNet.sign_transaction(reblog_data, reblogger.post_key, reblogger)
            end
          end # end of thread
        end # posts.each
      end # if posts.size != 0
      #puts "write block #{next_block_number} to file".cyan
      BotNet.save_block_number_to_file(next_block_number)
    end # if next_block_number >= max_block_number - delay_time
  end
end
