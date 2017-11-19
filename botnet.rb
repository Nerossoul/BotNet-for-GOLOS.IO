require_relative 'golosuser.rb'
require_relative 'botnetsettings'
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

  def read_users_data_from_file
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
    user_hashs = read_users_data_from_file
    user_hashs.each do |user|
      @users << GolosUser.new(user[:user_name], user[:post_key], user[:activ_key])
    end
  end

  def get_lust_post_data(user_name)
    lust_post_data = []
    max_number = get_account_history_max_number(user_name)
    limit_response = 1999
    api = Radiator::Api.new(chain: :golos, url: 'https://ws.golos.io')
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
      sleep(1)
    end
    return lust_post_data
  end

  def get_account_history_max_number(user_name)
    api = Radiator::Api.new(chain: :golos, url: 'https://ws.golos.io')
    puts "geting #{user_name.brown} account history max number"
    response = api.get_account_history(user_name, 800_000_000_000, 0)
    max_number = response['result'][0][0]
    sleep(1)
    puts "#{user_name.brown} account history max number is #{max_number}"
    return max_number
  end

  def sign_transaction(transaction_data, wif_key, user)
    tx = Radiator::Transaction.new(wif: wif_key, chain: :golos, url: 'https://ws.golos.io')
    puts "\n\r#{user.user_name.brown} sing transaction --> #{transaction_data}".green
    tx.operations << transaction_data
    transaction_signed = false
    retry_count = 0
    retry_delay = 6
    #check signing_transaction_now by this user/
    while user.signing_transaction_now == true do
      #puts "\n\r#{user.user_name.brown} signing another transaction now...WAITING 4 seconds"
      sleep(4)
    end
    user.signing_transaction_now = true
    while transaction_signed != true do
      begin
      response = tx.process(true)
      rescue Exception => e
      puts e.message.red
      puts "\n\rit\'s a error here, but im trying again in 15 sec".red.reverse_color
      sleep(15)
      response = tx.process(true)
      end
      #puts JSON.pretty_generate(response).brown
      if (response['error'] != nil && retry_count < 10)
        retry_count = retry_count + 1
        puts "\n\rWe 've got a ERROR MESSAGE NUMBER #{retry_count}'".red.reverse_color
        puts response['error']['message'].red
        puts "\n\rretry in #{retry_delay} seconds".red
        sleep(retry_delay)
      elsif response['result'] != nil
        sleep(4)
        user.signing_transaction_now = false
        puts "\n\r#{user.user_name.upcase} success at #{Time.now.utc}".green
        puts JSON.pretty_generate(response['result']).green
        transaction_signed = true
      else
        sleep(4)
        user.signing_transaction_now = false
        puts "\n\rTransaction ABORTED #{response['error']['message']}".red.reverse_color
        # todo puts this error message to error_log file
      end
    end
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

  def get_permission_to_run_thead
    working_thread_max = MAX_THREADS
    print "\n\rchecking permission to go on"
    while Thread.list.size >= working_thread_max do
      puts "\n\rВсего потоков: #{Thread.list.size - 1} / MAX:#{MAX_THREADS - 1}".red
      sleep(1)
    end
    puts " OK".green.bold
  end

  def whait_while_all_thread_are_done
    while Thread.list.size > 1 do
      puts "\n\rОжидаем завершения потоков: #{Thread.list.size - 1} / #{MAX_THREADS - 1}"
      #Thread.list.each {|t| puts t}
      sleep(3)
    end
    puts "JOB WELL DONE, press ENTER"
    good_bye_message = gets.chomp
    puts good_bye_message
  end

  def play_golos_loto
    parent_author = 'golos.loto'
    parent_author_lust_post_data = get_lust_post_data(parent_author)
    parent_permlink = parent_author_lust_post_data['op'][1]['permlink']
    title = ''
    json_metadata = ''
    @users.each do |user|
      get_permission_to_run_thead
      Thread::abort_on_exception = true
      Thread.new(user) do |user_of_this_thread|
        body = generate_golos_loto_ticket
        vote = create_vote_data(user_of_this_thread.user_name, parent_author, parent_permlink, 10000)
        comment = create_comment_data(parent_permlink, user_of_this_thread.user_name, title, body, json_metadata, parent_author)
        puts "\n\r#{user_of_this_thread.user_name.brown} vote for @#{parent_author}/#{parent_permlink}".blue
        sign_transaction(vote, user_of_this_thread.post_key, user_of_this_thread)
        puts "\n\r#{user_of_this_thread.user_name.brown} play loto @#{parent_author}/#{parent_permlink} post ticket numbers: #{body}".blue
        sign_transaction(comment, user_of_this_thread.post_key, user_of_this_thread)
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
        sign_transaction(vote, user_of_this_thread.post_key, user_of_this_thread)
      end
    end
  end

  def generate_golos_loto_ticket
    OFTEN_LOTTERY_NUMBERS.sample(5).sort.join(' ')
  end

  def launch_playing_lotos #now it launchs golos.loto only but soon it will play momentloto
    #it is Krasnoyarsk time
    golos_loto_lunch_time = [[17,20],[20,20],[23,20],[2,20],[7,5]]
    #momentloto_lunch_time = [[6:00], [11:00], [14:00], [17:00], [21:00], [02:00]]
    puts
    loop do
      t = Time.now
      print "."
      golos_loto_lunch_time.each do |time_x|
        if (t.hour == time_x[0] and t.min == time_x[1])
          puts "\n\rRUN IT NOW".red
          play_golos_loto
            sleep(65)
            t = Time.now
            puts "\n\rAll users begin to play loto at #{t.hour}:#{t.min}. Waiting for next lunch".reverse_color
        end
      end
      sleep(59)
    end
  end

  def get_user_vote_history(user_name, limit)
    user_vote_history = []
    max_number = get_account_history_max_number(user_name)
    limit_response = 1999
    api = Radiator::Api.new(chain: :golos, url: 'https://ws.golos.io')
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

  def did_i_vote_here(user_name, author, permlink)
    # todo
  end

  def get_reblog_history(user_name, period_hours) #it returns reblog history for lust puriod in hours
    user_reblog_history = []
    max_number = get_account_history_max_number(user_name)
    limit_response = 1999
    api = Radiator::Api.new(chain: :golos, url: 'https://ws.golos.io')
    puts "geting #{user_name.brown} reblogs"
    while max_number > 0 do
      limit_response = max_number - 1 if limit_response > max_number
      print "*"
      response = api.get_account_history(user_name, max_number, limit_response)
      response['result'].reverse_each do |result|
        if result[1]['op'][0] == 'custom_json' then
          response_json_array = JSON.parse(result[1]['op'][1]['json'])
          if response_json_array[0] == "reblog" then
            t = get_time_object_from_golos_timestamp(result[1]['timestamp'])
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

  def get_post_information(author, permlink)
    api = Radiator::Api.new(chain: :golos, url: 'https://ws.golos.io')
    print "Getting post information for #{author.brown}/#{permlink.brown} "
    response = api.get_content(author, permlink)
    #puts JSON.pretty_generate(response)
    post_information = {
              :author => response['result']['author'],
              :permlink =>  response['result']['permlink'],
              :mode =>  response['result']['mode'],
              :pending_payout_value => response['result']['pending_payout_value'].split(' ')[0].to_f,
              :cashout_time => get_time_object_from_golos_timestamp(response['result']['cashout_time']),
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
    upvote_list.each do |post|
      puts "\n\r************************"
      puts "\n\rUpvoting for #{post[:pending_payout_value].to_s.green} => #{post[:author].brown}/#{post[:permlink].brown}".reverse_color
      @users.each do |user|
        get_permission_to_run_thead
        Thread::abort_on_exception = true
        Thread.new(user, post[:author], post[:permlink], post[:active_votes]) do |user, author, permlink, active_votes|
          post_been_voted = false
          active_votes.each { |elem| post_been_voted = true if user.user_name == elem['voter'] }
          if post_been_voted then
            puts "\n\r#{user.user_name.upcase} already voted for @#{author}/#{permlink}".blue
          else
            if user.till_what_time_to_sleep > Time.now.utc then
              puts "\n\r#{user.user_name.brown} sleeping till #{user.till_what_time_to_sleep}".reverse_color
            else
              user.get_user_info
              if user.future_voting_power < 77 then
                puts "\n\r#{user.user_name.brown} Voting Power now #{user.voting_power.to_s.red}-->#{user.future_voting_power.to_s.red} go to sleep".reverse_color
                user.till_what_time_to_sleep = Time.now.utc + 60*60*23
              else
                user.future_voting_power = user.future_voting_power - ((user.future_voting_power/100*0.5).round(2))
                puts "\n\r#{user.user_name.brown} Voting Power now #{user.voting_power.to_s.green}-->#{user.future_voting_power.to_s.green}".reverse_color
                vote = create_vote_data(user.user_name, author, permlink, 10000)
                puts "\n\r#{user.user_name.brown} vote for @#{author}/#{permlink}."
                sign_transaction(vote, user.post_key, user)
              end
            end
          end
        end #end of Thread
      end #end users.each
      sleeping_users_count = 0
      @users.each do |user|
          sleeping_users_count = sleeping_users_count + 1 if user.till_what_time_to_sleep > Time.now.utc
      end
      if sleeping_users_count == @users.size then
        puts "\n\rEverybody are sleeping NOW #{Time.now.utc}".reverse_color
      else
        puts "\n\rStarting next post #{Time.now.utc}".reverse_color
      end
    end
  end

  def get_time_object_from_golos_timestamp(timestamp)
    timestamp = timestamp.split('T')
    timestamp_date_array = timestamp[0].split('-')
    timestamp_time_array = timestamp[1].split(':')
    timestamp_converted = Time.new(timestamp_date_array[0], timestamp_date_array[1], timestamp_date_array[2], timestamp_time_array[0], timestamp_time_array[1], timestamp_time_array[2], "+00:00")
    return timestamp_converted.utc
  end

  def folow_vote_history(user_vote_history) #todo try a
    user_vote_history.each do |vote_data_from_history|
      puts vote_data_from_history['op'][1]['author']
      puts vote_data_from_history['op'][1]['permlink']
      puts "******"
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
