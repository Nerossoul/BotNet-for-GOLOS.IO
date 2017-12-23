require_relative 'golosuser.rb'
require_relative 'botnetsettings.rb'
require 'securerandom'
require 'json'

# BotNet is keeping golos users array and drive each over
#
class BotNet

  attr_reader(:users)

  def initialize
    @users = []
    create_users
  end

  def self.read_users_data_from_file
    current_path = File.dirname(__FILE__)
    file_name = current_path + '/botlist.txt'
    if File.exist?(file_name)
      f = File.new(file_name, 'r:UTF-8')
      users_array = f.readlines
      f.close
      users_hashs = []
      users_array.each do |user_data|
        user_auth = user_data.split
        users_hashs << {
          user_name: user_auth[0],
          post_key: user_auth[1],
          activ_key: user_auth[2]
        }
      end
      return users_hashs
    else
      puts "file #{file_name} not found"
    end
  end

  def create_users
    user_hashs = BotNet.read_users_data_from_file
    user_count = 0
    user_hashs.each do |user|
      user_count += 1
      print "#{user_count}. "
      @users << GolosUser.new(user[:user_name], user[:post_key], user[:activ_key])
    end
  end

  def get_lust_post_data(user_name)
    lust_post_data = []
    max_number = get_account_history_max_number(user_name)
    limit_response = 1999
    options = GOLOSOPTIONS.merge({url: NODES_URLS.sample})
    api = Radiator::Api.new(options)
    while max_number > 0 do
      puts "Получаем данные последнего поста #{user_name.brown}"
      limit_response = max_number - 1 if limit_response > max_number
      response = api.get_account_history(user_name, max_number, limit_response)
      #puts JSON.pretty_generate(response)
      response['result'].reverse_each do |result|
        if result[1]['op'][0] == 'comment' then
          if (result[1]['op'][1]['author'] == user_name && result[1]['op'][1]['parent_author'] == '') then
            lust_post_data = result[1]
            max_number = 0
            break
          end
        end
      end
      max_number = max_number - 2000
      #sleep(1)
    end
    return lust_post_data
  end

  def get_account_history_max_number(user_name)

    puts "geting #{user_name.brown} account history max number"
    got_max_number = false
    while got_max_number != true
      begin
        options = GOLOSOPTIONS.merge({url: NODES_URLS.sample})
        api = Radiator::Api.new(options)
        response = api.get_account_history(user_name, 800_000_000_000, 0)
        max_number = response['result'][0][0]
        got_max_number = true
      rescue Exception => e
        puts "get_account_history_max_number ERROR".red
        puts e # e.message.red
        print e.backtrace.join("\n")
        sleep(5)
      end
    end
    #sleep(1)
    puts "#{user_name.brown} account history max number is #{max_number}"
    return max_number
  end

  def self.sign_transaction(transaction_data, wif_key, user)
    options = GOLOSOPTIONS.merge({wif: wif_key, recover_transactions_on_error: false, url: NODES_URLS.sample})
    tx = Radiator::Transaction.new(options)
    tx.operations << transaction_data
    transaction_signed = false
    retry_count = 0
    retry_delay = 6
    #check signing_transaction_now by this user/
    while user.signing_transaction_now == true do
      #puts "\n\r#{user.user_name.brown} signing another transaction now...WAITING 1 second"
      sleep(0.5)
    end
    user.signing_transaction_now = true
    puts "\n\r#{user.user_name.brown} sing transaction ► #{transaction_data}".green
    while transaction_signed != true do
        begin
        response = tx.process(true)
        # todo time.now user.user_name and response put to log file
        rescue Exception => e
        puts "ТУТ ИДЕТ ВСЕ СООБЩЕНИЕ ОШИБКИ ЭТОТ ТЕКСТ НАДО ОТПРАВИТЬ inertia186 КАК ISSUE".red.reverse_color
        puts e # e.message.red
        print e.backtrace.join("\n")
        puts "\n\r#{user.user_name.brown} got a error here. Try again in 15 sec".red.reverse_color
        sleep(15)
        response = {}
        response['error'] = {'message' => "NO TRANSACTION TO BLOKCHAIN--==>#{e.message}<==--"}
        end
      #puts JSON.pretty_generate(response).brown
      if (response['error'] != nil && retry_count < 10)
        retry_count = retry_count + 1
        puts "\n\rWe 've got a ERROR MESSAGE NUMBER #{retry_count}'".red.reverse_color
        if response['error']['message'].include? DUPLICATE_TRANSACTION_ERROR
          puts "ERROR: #{user.user_name}  trying duplicate transaction ► #{transaction_data}|Transaction ABORTED".red.reverse_color
          sleep(4)
          transaction_signed = true
          user.signing_transaction_now = false
        elsif response['error']['message'].include? ALREDY_REBLOGGED_ERROR
          puts "ERROR: #{user.user_name}  already reblogged this post ► #{transaction_data}|Transaction ABORTED".red.reverse_color
          sleep(4)
          transaction_signed = true
          user.signing_transaction_now = false
        elsif response['error']['message'].include? CHECK_MAX_BLOCK_AGE_ERROR
          puts "ERROR: #{user.user_name}  MAX_BLOCK_AGE is wrong ► #{transaction_data} \n\r Change node".red.reverse_color
          options = GOLOSOPTIONS.merge({wif: wif_key, recover_transactions_on_error: false, url: NODES_URLS.sample})
          tx = Radiator::Transaction.new(options)
          tx.operations << transaction_data
          sleep(4)
          user.signing_transaction_now = false
        else
          puts response['error']['message'].red
          puts "\n\rretry in #{retry_delay} seconds".red
          sleep(retry_delay)
        end
      elsif response['result'] != nil
        sleep(4)
        puts "\n\r#{user.user_name.upcase} success sing transaction ► ".green +
        " #{transaction_data} at #{Time.now.utc}\n\r ".green +
        " #{JSON.pretty_generate(response['result'])}".green
        transaction_signed = true
        user.signing_transaction_now = false
      else
        sleep(4)
        puts "\n\rTransaction ABORTED #{response['error']['message']}".red
        transaction_signed = true
        user.signing_transaction_now = false
        # todo puts this error message to error_log file
      end
    end
  end

  def self.create_reblog_data(user_name, author, permlink)
    data = [
      :reblog, {
        account: user_name,
        author: author,
        permlink: permlink
      }
    ]
    reblog_custom_json = {
      type: :custom_json,
      id: 'follow',
      required_auths: [],
      required_posting_auths: [user_name],
      json: data.to_json
    }
    return reblog_custom_json
  end

  def create_vote_data(voter, author, permlink, weight)
    vote = {
      type: :vote,
      voter: voter,
      author: author,
      permlink: permlink,
      weight: weight.to_i
    }
    return vote
  end

  def create_comment_data(parent_permlink, author, title, body, json_metadata, parent_author)
    permlink = get_comment_permlink(parent_permlink)
    comment = {
      type: :comment,
      parent_permlink: parent_permlink,
      author: author,
      permlink: permlink,
      title: title,
      body: body,
      json_metadata: json_metadata,
      parent_author: parent_author
    }
    return comment
  end

  def get_comment_permlink(parent_permlink)
    t = Time.now
    permlink = "re-" + parent_permlink + t.strftime("-%Y%m%dt%H%M%S%L") + SecureRandom.hex(1)
    return permlink
  end

  def self.get_permission_to_run_thead
    working_thread_max = MAX_THREADS
    #print "\n\rchecking permission to go on"
    while Thread.list.size >= working_thread_max do
      #puts "\n\rThreads: #{Thread.list.size - 1} / MAX:#{MAX_THREADS}".cyan
      sleep(0.1)
    end
    #puts " OK".green.bold
  end

  def self.wait_while_all_threads_are_done
    while Thread.list.size > 1 do
      #puts "\n\rОжидаем завершения потоков: #{Thread.list.size - 1} / #{MAX_THREADS - 1}"
      #Thread.list.each {|t| puts t}
      sleep(0.1)
    end
    #puts "JOB WELL DONE"
  end

  def play_golos_loto
    parent_author = 'golos.loto'
    parent_author_lust_post_data = get_lust_post_data(parent_author)
    parent_permlink = parent_author_lust_post_data['op'][1]['permlink']
    title = ''
    json_metadata = ''
    post_information = get_post_information(parent_author, parent_permlink)
    @users.each do |user|
      BotNet.get_permission_to_run_thead
      Thread::abort_on_exception = true
      Thread.new(user) do |user_of_this_thread|
        body = generate_golos_loto_ticket
        vote = create_vote_data(user_of_this_thread.user_name, parent_author, parent_permlink, 10000)
        comment = create_comment_data(parent_permlink, user_of_this_thread.user_name, title, body, json_metadata, parent_author)
        post_been_voted = false
        post_information[:active_votes].each do |elem|
          post_been_voted = true if user_of_this_thread.user_name == elem['voter']
        end
        if post_been_voted then
          puts "\n\r#{user_of_this_thread.user_name.upcase} already voted for @#{parent_author}/#{parent_permlink}".blue
        else
          BotNet.sign_transaction(vote, user_of_this_thread.post_key, user_of_this_thread)
        end
        BotNet.sign_transaction(comment, user_of_this_thread.post_key, user_of_this_thread)
      end
    end
  end

  def play_moment_loto
    parent_author = 'momentloto'
    parent_author_lust_post_data = get_lust_post_data(parent_author)
    parent_permlink = parent_author_lust_post_data['op'][1]['permlink']
    @users.each do |user|
      get_permission_to_run_thead
      Thread::abort_on_exception = true
      Thread.new(user) do |user_of_this_thread|
        vote = create_vote_data(user_of_this_thread.user_name, parent_author, parent_permlink, 100)
        puts "\n\r#{user_of_this_thread.user_name.brown} vote for @#{parent_author}/#{parent_permlink}".blue
        BotNet.sign_transaction(vote, user_of_this_thread.post_key, user_of_this_thread)
      end
    end
  end

  def generate_golos_loto_ticket
    OFTEN_LOTTERY_NUMBERS.sample(5).sort.join(' ')
  end

  def launch_playing_lotos #now it launchs golos.loto only but soon it will play momentloto
    #it is Krasnoyarsk time
    golos_loto_lunch_time = GOLOS_LOTO_LUNCH_TIME
    #momentloto_lunch_time = MOMENTLOTO_LUNCH_TIME
    puts Time.now
    loop do
      t = Time.now
      print "."
      golos_loto_lunch_time.each do |time_x|
        if (t.hour == time_x[0] and t.min == time_x[1])
          puts "\n\rRUN IT NOW".red
          play_golos_loto
          BotNet.wait_while_all_threads_are_done
            t = Time.now
            puts "\n\rAll users finished playing loto at #{t.hour}:#{t.min}. Waiting for next lunch".reverse_color
        end
      end
      sleep(59)
    end
  end

  def get_user_vote_history(user_name, limit)
    user_vote_history = []
    max_number = get_account_history_max_number(user_name)
    limit_response = 1999
    options = GOLOSOPTIONS.merge({url: NODES_URLS.sample})
    api = Radiator::Api.new(options)
    while max_number > 0 do
      puts "\n\rgetting #{user_name.brown} lust #{limit} upvotes"
      limit_response = max_number - 1 if limit_response > max_number
      response = api.get_account_history(user_name, max_number, limit_response)
      #puts JSON.pretty_generate(response)
      response['result'].reverse_each do |result|
        if result[1]['op'][0] == 'vote' then
          if result[1]['op'][1]['voter'] == user_name then
            user_vote_history << result[1]
            if user_vote_history.size == limit then
              max_number = 0
              break
            end
          end
        end
      end
      max_number = max_number - 2000
      sleep(1)
    end
    puts "\n\r*********************"
    return user_vote_history
  end


  def get_reblog_history(user_name, period_hours) #it returns reblog history for lust puriod in hours
    user_reblog_history = []
    max_number = get_account_history_max_number(user_name)
    limit_response = 1999
    options = GOLOSOPTIONS.merge({url: NODES_URLS.sample})
    api = Radiator::Api.new(options)
    puts "geting #{user_name.brown} reblogs"
    while max_number > 0 do
      limit_response = max_number - 1 if limit_response > max_number
      print "."
      response = api.get_account_history(user_name, max_number, limit_response)
      response['result'].reverse_each do |result|
        if result[1]['op'][0] == 'custom_json' then
          response_json_array = JSON.parse(result[1]['op'][1]['json'])
          if response_json_array[0] == "reblog" then
            t = BotNet.get_time_object_from_golos_timestamp(result[1]['timestamp'])
            t = (Time.now.utc - t)/3600
            if t.to_i >= period_hours then
              max_number = 0
              break
            end
            user_reblog_history << response_json_array[1]
          end
        end
      end
      max_number = max_number - 2000
      sleep(1)
    end
    puts "DONE".green.bold
    puts "*****************"
    return user_reblog_history
  end

  def self.save_block_number_to_file(max_block_number)
    current_path = "/" + File.dirname(__FILE__)
    file_name = current_path + "/resources/maxblocknumber.txt"
    f = File.new(file_name, "w")
    f.puts max_block_number
    f.close
  end

  def self.get_lust_max_block_number_from_file
    current_path = "/" + File.dirname(__FILE__)
    max_block_number = read_from_file(current_path + "/resources/maxblocknumber.txt")
    max_block_number[0].to_i
  end

  def self.get_max_block_number
    options = GOLOSOPTIONS.merge({url: NODES_URLS.sample})
    api = Radiator::Api.new(options)
    got_block_number = false
    while got_block_number != true
      begin
        response = api.get_dynamic_global_properties
        got_block_number = true
      rescue Exception => e
        puts "GET_BLOCK_NUMBER ERROR".red
        puts e # e.message.red
        print e.backtrace.join("\n")
      end
    end
    response['result']['head_block_number']
  end

  def self.get_block(block_number)
    options = GOLOSOPTIONS.merge({url: NODES_URLS.sample})
    api = Radiator::Api.new(options)
    got_block = false
    while got_block != true
      begin
        response = api.get_block(block_number)
        got_block = true
      rescue Exception => e
      puts "GET_BLOCK ERROR".red
      puts e # e.message.red
      print e.backtrace.join("\n")
      end
    end
    #puts JSON.pretty_generate(response)
    return response
  end

  def self.get_posts_by_tag_from_block(good_tag_array, block_data)
  posts_by_tag = []
  #  puts JSON.pretty_generate(block_data['result']["transactions"])
    if block_data['result'] != nil
      block_data['result']["transactions"].each do |transaction|
        if (transaction['operations'][0][0] == 'comment') && (transaction['operations'][0][1]['parent_author'] == '')
          tags = JSON.parse(transaction['operations'][0][1]["json_metadata"])["tags"]
          if tags != nil
            tags.each do |tag|
              # puts "-->" + tag
              if good_tag_array.include?(tag)
                # puts "timestamp: #{block_data["result"]["timestamp"]}"
                # puts transaction['operations'][0][0]
                # puts transaction['operations'][0][1]['parent_author']
                # puts transaction['operations'][0][1]['author']
                # puts transaction['operations'][0][1]['permlink']
                # puts tags
                # puts "*************************"
                posts_by_tag << { 'author' => transaction['operations'][0][1]['author'],
                                  'permlink' => transaction['operations'][0][1]['permlink'],
                                  'timestamp' => block_data['result']['timestamp'] }
                break
              end # if
            end # tags.each
          end # if tags != nil
        end # if
      end # block_data_operations.each
    end
    posts_by_tag
  end

  def self.get_posts_array_for_vote(max_block_number)
    posts_array_for_vote = []
    current_path = "/" + File.dirname(__FILE__)
    posts_array_for_vote = posts_array_for_vote + read_from_file(current_path + "/resources/posts.txt")
    posts_array_for_vote.each do |post|
    post = JSON.parse(post.strip.to_json)
    end
    min_block_number = get_lust_max_block_number_from_file
    if (max_block_number - min_block_number) > ((FIRST_PAYOUT_PERIOD + 24)*60*60/3)
      min_block_number = max_block_number-(FIRST_PAYOUT_PERIOD + 24)*60*60/3
    end
    puts "#{max_block_number.to_i} ---> #{min_block_number}"
    (max_block_number - min_block_number).times do |i|
      puts "#{i}: #{(max_block_number - i).to_s.green} --> #{min_block_number} :#{(max_block_number - i - min_block_number).to_s}"
      block_data = get_block(max_block_number - i)
      posts_from_block = get_posts_by_tag_from_block(GOOD_TAG_ARRAY, block_data)
      posts_array_for_vote = posts_array_for_vote + posts_from_block
    end
    posts_array_for_vote_uniq = post_array_uniqalization(posts_array_for_vote)
    posts_array_for_vote_clean = delete_old_posts_from_array(posts_array_for_vote_uniq)
    save_to_file_posts_array(posts_array_for_vote_clean)
    save_block_number_to_file(max_block_number)
    return posts_array_for_vote_clean
  end

  def self.save_to_file_posts_array(posts_array_for_vote)
    current_path = "/" + File.dirname(__FILE__)
    file_name = current_path + "/resources/posts.txt"
    f = File.new(file_name, "w")
    posts_array_for_vote.each do |line|
      f.puts line
    end
    f.close
  end

  def self.delete_old_posts_from_array(array_start)
    array_result = []
    puts "delete_old_posts_from_array".red
    puts array_start
    puts "^^^^^^^^^^^^^^^^^".red
    array_start.each do |array_start_elem|
      time = Time.now.utc
      print "OLD? #{array_start_elem} time #{Time.now.utc}"
      if get_time_object_from_golos_timestamp(array_start_elem['timestamp']) > (time - (FIRST_PAYOUT_PERIOD + 24)*60*60)
        puts "<<--GOOD POST ADDED TO ARRAY".green
        array_result << array_start_elem
      else
        puts "<<--OLD POST MOVE TO TRASH".red
      end
    end
    array_result
  end

  def self.string_to_hash(string)
    print "#{string} --> it is #{string.class}-->"
    if string.class.to_s != 'Hash'
      puts " convert to Hash"
      return eval(string)
    else
      puts " alredy Hash"
      return string
    end
  end

  def self.post_array_uniqalization(array_start)
    puts "Uniqalization of this stack".red
    puts array_start
    puts "^^^^^^^^^^^^^^^^^".red
    array_result = []
    array_result2 = []
    array_start.each do |element|
      elem = string_to_hash(element)
      array_result << {"author" => elem["author"], "permlink"=> elem["permlink"]}
    end
    array_result.uniq!
    array_result.each do |array_result_elem|
      array_start.each do |array_start_elem|
        if (array_result_elem['author']==array_start_elem['author']) && (array_result_elem['permlink']==array_start_elem['permlink'])
          array_result_elem['timestamp'] = array_start_elem['timestamp']
          array_result2 << array_start_elem
          break
        end
      end
    end
    puts "^^^^^^^^^^^^^^^^^".red
    array_result2
  end

  def get_post_information(author, permlink)
    options = GOLOSOPTIONS.merge({url: NODES_URLS.sample})
    api = Radiator::Api.new(options)
    print "Getting post information for #{author.brown}/#{permlink.brown} "
    got_post_information = false
    while got_post_information != true
      begin
        response = api.get_content(author, permlink)
        #puts JSON.pretty_generate(response)
        got_post_information = true
      rescue Exception => e
        puts "get_post_information ERROR".red
        puts e # e.message.red
        print e.backtrace.join("\n")
        sleep(5)
      end
    end
    post_information = {
              :author => response['result']['author'],
              :permlink =>  response['result']['permlink'],
              :mode =>  response['result']['mode'],
              :pending_payout_value => response['result']['pending_payout_value'].split(' ')[0].to_f,
              :cashout_time => BotNet.get_time_object_from_golos_timestamp(response['result']['cashout_time']),
              :active_votes =>response['result']['active_votes']
    }
    print "DONE ".green.bold
    return post_information
  end

  def create_upvote_list_from_reblog_history(user_reblog_history)
    upvote_list = []
    user_reblog_history.each do |post_info|
      post_information = get_post_information(post_info['author'], post_info['permlink'])
      print post_information[:mode]
      if post_information[:mode] == 'first_payout' then
        puts " ADD to LIST".green.bold
        upvote_list << post_information
      else
        puts " SKIP".red.bold
      end
    end
    upvote_list.sort_by! {|elem| elem[:pending_payout_value]}.reverse!
    return upvote_list
  end

  def vote_by_each_user_for_upvote_list(upvote_list)
    @users.each do |user|
    user.get_user_info
    user.future_voting_power = user.actual_voting_power
    end
    upvote_list.each do |post|
      puts "\n\r************************"
      puts "\n\rUpvoting for #{post[:pending_payout_value].to_s.green} => #{post[:author].brown}/#{post[:permlink].brown}".reverse_color
      @users.each do |user|
        BotNet.get_permission_to_run_thead
        Thread::abort_on_exception = true
        Thread.new(user, post[:author], post[:permlink], post[:active_votes]) do |user, author, permlink, active_votes|
          post_been_voted = false
          active_votes.each { |elem| post_been_voted = true if user.user_name == elem['voter'] }
          if post_been_voted then
            puts "\n\r#{user.user_name.upcase} already voted for @#{author}/#{permlink}".blue
          else
            user_min_voting_power = MIN_VOTING_POWER - user.voiting_credit
            if user_min_voting_power < 83 then
              user_min_voting_power = 83
            end
            puts "#{user.user_name}:user.future_voting_power = #{user.future_voting_power}, user_min_voting_power = #{user_min_voting_power.round(2)}".gray +
            " (MIN_VOTING_POWER = #{MIN_VOTING_POWER}, user.voiting_credit = #{user.voiting_credit})".gray
            if (user.future_voting_power > user_min_voting_power)
              user.future_voting_power = user.future_voting_power - ((user.future_voting_power/100*0.5).round(2))
              puts "\n\r#{user.user_name.brown} Voting Power now #{user.actual_voting_power.to_s.green} ► #{user.future_voting_power.to_s.green}".reverse_color
              vote = create_vote_data(user.user_name, author, permlink, 10000)
              # puts "\n\r#{user.user_name.brown} vote for @#{author}/#{permlink}."
              BotNet.sign_transaction(vote, user.post_key, user)
            end
          end
        end # end of Thread
      end # end users.each
    users_with_minimum_voting_power = 0
    @users.each do |user|
      user_min_voting_power = MIN_VOTING_POWER - user.voiting_credit
      if user_min_voting_power < 83 then
        user_min_voting_power = 83
      end
      users_with_minimum_voting_power += 1 if user.future_voting_power <= user_min_voting_power
    end
    puts "Users_with_minimum_voting_power = #{users_with_minimum_voting_power}/#{@users.size}".cyan
    if @users.size == users_with_minimum_voting_power
      puts "Each user reach minimum voting power!".green.reverse_color
      break
    end
    end # end of upvote_list.each
  end

  def self.get_time_object_from_golos_timestamp(timestamp)
    timestamp = timestamp.split('T')
    timestamp_date_array = timestamp[0].split('-')
    timestamp_time_array = timestamp[1].split(':')
    timestamp_converted = Time.new(timestamp_date_array[0], timestamp_date_array[1], timestamp_date_array[2], timestamp_time_array[0], timestamp_time_array[1], timestamp_time_array[2], "+00:00")
    return timestamp_converted.utc
  end

  def create_gbg_transfer_data(sender, recipient, amount, memo)
    transfer = {
  type: :transfer,
  from: sender,
  to: recipient,
  amount: amount,
  memo: memo
                }
    return transfer
  end

  def self.read_from_file(file_name)
    if File.exists?(file_name)
          f= File.new(file_name, 'r:UTF-8')
          lines = f.readlines
          f.close
          return lines
    else
          return []
    end
  end

  def self.create_cool_memos_array
    current_path = "/" + File.dirname(__FILE__)
    read_from_file(current_path + "/resources/aforisms.txt")
  end


  def gbg_concentration(recipient)
    memos = BotNet.create_cool_memos_array
    @users.each do |user|
      if user.user_name != recipient
      transaction_data = create_gbg_transfer_data(user.user_name, recipient, user.gbg, memos.sample)
      BotNet.sign_transaction(transaction_data, user.activ_key, user)
      else
      puts "I do not want to transfer to myself. #{user.user_name.upcase}".green
      end
    end
  end

  def folow_vote_history(user_vote_history) #todo try a
    user_vote_history.each do |vote_data_from_history|
      puts vote_data_from_history['op'][1]['author']
      puts vote_data_from_history['op'][1]['permlink']
      puts "***************"
    # @users.each do |user|
      #  get_permission_to_run_thead
      #  Thread::abort_on_exception = true
      #  Thread.new(user.user_name, user.post_key) do |user_name, post_key|
      #    vote = create_vote_data(user_name, parent_author, parent_permlink, 100)
      #    puts "#{user_name.brown} vote for @#{parent_author}/#{parent_permlink}".blue
          #sign_transaction(vote, post_key)
      #  end
      #end
    end
  end
end #class end
