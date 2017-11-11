require_relative 'golosuser.rb'
require_relative 'botnetsettings'
require 'securerandom'
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
      puts "Получаем данные последнего поста #{user_name}"
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
    response = api.get_account_history(user_name, 800_000_000_000, 0)
    max_number = response['result'][0][0]
    sleep(1)
    return max_number
  end

  def sign_transaction(transaction_data, wif_key)
    tx = Radiator::Transaction.new(wif: wif_key, chain: :golos, url: 'https://ws.golos.io')
    puts transaction_data
    tx.operations << transaction_data
    transaction_signed = false
    while transaction_signed != true do
      begin
      response = tx.process(true)
      rescue
      puts "its a error here, but im trying again".red
      response = tx.process(true)
      end
      #puts JSON.pretty_generate(response).brown
      if response['error'] != nil
        puts response['error']['message'].red
        puts "retry in 6 seconds".red
        sleep(6)
      elsif response['result'] != nil
        puts "Success".green
        puts JSON.pretty_generate(response['result']).green
        transaction_signed = true
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
    puts 'checking permission to go on'
    while Thread.list.size >= working_thread_max do
      puts "Всего потоков: #{Thread.list.size - 1} / MAX:#{MAX_THREADS - 1}".red
      sleep(1)
    end
    puts "i ve got permission obtained to go on".green
  end

  def whait_while_all_thread_are_done
    while Thread.list.size > 1 do
      puts "Ожидаем завершения потоков: #{Thread.list.size - 1} / #{MAX_THREADS - 1}"
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
    parent_author_lust_post_data = nil
    title = ''
    json_metadata = ''
    @users.each do |user|
      get_permission_to_run_thead
      Thread::abort_on_exception = true
      Thread.new(user.user_name, user.post_key) do |user_name, post_key|
        body = generate_golos_loto_ticket
        vote = create_vote_data(user_name, parent_author, parent_permlink, 100)
        comment = create_comment_data(parent_permlink, user_name, title, body, json_metadata, parent_author)
        puts "#{user_name} vote for @#{parent_author}/#{parent_permlink}".blue
        sign_transaction(vote, post_key)
        puts "#{user_name} wiat 6 seconds between queries to blockchain".blue
        sleep(6)
        puts "#{user_name} play loto @#{parent_author}/#{parent_permlink} post ticket bumbers: #{body}".blue
        puts comment
        sign_transaction(comment, post_key)
      end
    end
  end

  def generate_golos_loto_ticket
    OFTEN_LOTTERY_NUMBERS.sample(5).sort.join(' ')
  end

  def lunch_playing_golos_loto
    #it is Krasnoyarsk time
    lunch_time = [[17,20],[20,20],[23,20],[2,20],[5,20]]
    loop do
      t = Time.now
      puts "#{t.hour}:#{t.min}"
      lunch_time.each do |time_x|
        if (t.hour == time_x[0] and t.min == time_x[1])
          puts "RUN IT NOW".red
          play_golos_loto
          3600.times do
            t = Time.now
            puts "#{t.hour}:#{t.min}"
            sleep(1)
          end
        end
      end
      sleep(1)
    end
  end
end #class end
