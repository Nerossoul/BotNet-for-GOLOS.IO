require 'tiny_tds'
require "json"
require_relative 'stringformat.rb'

class BlackList

    @@USERS_NOT_CREATE_STAT = ['golosboard',
                                'coinbank',
                                'booster',
                                'dobryj.kit',
                                'arcange',
                                'radogost']
    @@all_upvot50_50_posts = nil
    @@user_counter = 0

  def self.get_all_user_votes(user_name)
    client = TinyTds::Client.new username: 'golos', password: 'golos', host: 'sql.golos.cloud', port: 1433, database: 'DBGolos'
    print "Get_votes:"
    if client.active? == true then print '->' end
    query_done = false
    while query_done != true
      begin
        tsql = "SELECT author, permlink, timestamp FROM TxVotes WHERE voter='#{user_name}' AND weight > 0 " # поработать над уменьшением ответа убрать голосования за лото и доску почета
        result = client.execute(tsql)
        user_votes = []
        result.each do |row|
            user_votes << row
        end
        query_done = true
      rescue
        print "."
        sleep(1)
      end
    end
    client.close
    print 'ok '.green
    user_votes
  end

  def self.get_all_upvot50_50_posts
  client = TinyTds::Client.new username: 'golos', password: 'golos', host: 'sql.golos.cloud' , port: 1433, database: 'DBGolos'
  if client.active? == true then print '->' end
  query_done = false
  print 'Get_all_upvot50_50_posts:'
  while query_done != true
    begin
      tsql = "SELECT author, permlink FROM TxComments WHERE parent_author = '' AND json_metadata LIKE '%\"ru--apvot50-50\"%'"
      result = client.execute(tsql)
      all_upvot50_50_posts = []
      result.each do |row|
        all_upvot50_50_posts << row
      end
      query_done = true
    rescue
      print "."
      sleep(1)
    end
  end
  client.close
  print 'ok '.green
  all_upvot50_50_posts.uniq!
  end


  def self.get_voted_posts_upvote50_50(user_name)
    if @@all_upvot50_50_posts == nil
      @@all_upvot50_50_posts = get_all_upvot50_50_posts_from_file
    end
    all_upvot50_50_posts = @@all_upvot50_50_posts
    all_upvot50_50_posts.uniq!
    all_user_votes = get_all_user_votes(user_name)
    all_user_votes.uniq!
    result = []
    all_upvot50_50_posts.each do |post|
      all_user_votes.each do |vote|
        if post['author'] == vote['author'] &&  post['permlink'] == vote['permlink']

          post_reward_time =  BotNet.get_time_object_from_golos_timestamp(DateTime.parse(post['timestamp']).to_s)
          vote_time =  BotNet.get_time_object_from_golos_timestamp(vote['timestamp'].to_datetime.to_s)
          #print "post time #{post_reward_time} --> vote time #{vote_time}"
          if vote_time < post_reward_time
            #puts "ad this upvote".green
            result << post
          end
        end
      end
    end
    result
  end

  def self.get_all_user_transfers_memo(user_name)
    client = TinyTds::Client.new username: 'golos', password: 'golos', host: 'sql.golos.cloud', port: 1433, database: 'DBGolos'
    print "Get_transfers:"
    if client.active? == true then print '->' end
    query_done = false
    while query_done != true
      begin
        transfers = []
        tsql = "SELECT [from], memo FROM TxTransfers WHERE type = 'transfer' AND [to] = '#{user_name}' AND NOT [from] = 'robot' AND NOT [from] = 'golos.loto'"
        result = client.execute(tsql)
        sleep(1)
        result.each do |row|
          transfers << row
        end
        query_done = true
      rescue
        print "."
        sleep(1)
      end
    end
  client.close
  print 'ok '.green
  transfers
  end

# old -> version 1.01 new method if --> self.get_transfers_without_link_and_paid_posts(user_name)
  def self.get_paid_posts(user_name)
    trasnfers = get_all_user_transfers_memo(user_name)
    all_paid_posts = []
    trasnfers.each do |transfer|
      if transfer['memo'].include? '@'
        split_memo = transfer['memo'].split('@')
        split_memo.size.times do |i|
          if i != 0
            post = split_memo[i].split('/')
            post_author = post[0]
            post_permlink = post[1]
            if !(post_author.include? ' ') && (post_permlink != nil)
              post_permlink = post_permlink.split(' ')[0]
              all_paid_posts << {"author"=>post_author, "permlink"=>post_permlink.split(' ')[0]}
            end
          end
        end
      end
    end
    all_paid_posts
  end


  def self.get_transfers_without_link_and_paid_posts(user_name)
    trasnfers = get_all_user_transfers_memo(user_name)
    all_paid_posts = []
    transfers_without_link = {}
    trasnfers.each do |transfer|
      if transfer['memo'].include? '@'
        split_memo = transfer['memo'].split('@')
        split_memo.size.times do |i|
          if i != 0
            post = split_memo[i].split('/')
            post_author = post[0]
            post_permlink = post[1]
            if !(post_author.include? ' ') && (post_permlink != nil)
              post_permlink = post_permlink.split(' ')[0]
              all_paid_posts << {"author"=>post_author, "permlink"=>post_permlink.split(' ')[0]}
            else
              if transfers_without_link[transfer['from']] == nil #here will be bug hash massive need here
                transfers_without_link[transfer['from']] = 1
              else
                transfers_without_link[transfer['from']] += 1
              end
            end
          end
        end
      end
    end
    [all_paid_posts, transfers_without_link]
  end

  def self.get_post_paid_status(user_name)
    @@user_counter += 1
    print "#{@@user_counter}. Create stat for".green + " #{user_name.upcase} ".brown
    post_paid_status = []
    voted_posts_upvote50_50 = get_voted_posts_upvote50_50(user_name)
    paid_posts = get_paid_posts(user_name)
      voted_posts_upvote50_50.each do |voted_post|
        compare_variable = {"author"=>voted_post["author"], "permlink"=>voted_post["permlink"]}
        post_paid_status << {"author"=>voted_post["author"], "permlink"=>voted_post["permlink"], "paid" => (paid_posts.include? compare_variable)} #bug need format voted post
      end
    post_paid_status
  end

  def self.create_black_list(user_name)
    black_list = {} # author => [voted, paid]
    result_black_list = []
    post_paid_status = get_post_paid_status(user_name)
    post_paid_status.each do |post|
      if black_list[post["author"]] != nil
        black_list[post["author"]][0] += 1
        black_list[post["author"]][1] += 1 if post["paid"] == true
      else
        black_list[post["author"]] = [0,0]
        black_list[post["author"]][0] += 1
        black_list[post["author"]][1] += 1 if post["paid"] == true
      end
    end
    black_list.map do |key, value|
      if value[0] > 3
      result_black_list << "#{user_name}/#{key}" if (((value[1].to_f)/(value[0].to_f))*100) < 80
      end
    end
    puts 'DONE'.green.bold
    result_black_list
  end

  def self.create_stat(user_name)
    black_list = {} # author => [voted, paid]
    post_paid_status = get_post_paid_status(user_name)
    post_paid_status.each do |post|
      if black_list[post["author"]] != nil
        black_list[post["author"]][0] += 1
        black_list[post["author"]][1] += 1 if post["paid"] == true
      else
        black_list[post["author"]] = [0,0]
        black_list[post["author"]][0] += 1
        black_list[post["author"]][1] += 1 if post["paid"] == true
      end
    end
    black_list
  end

  def self.create_common_black_list(users_array)
    common_black_list = []
    users_array.each do |user|
      create_black_list(user).each do |elem|
        common_black_list << elem
      end
    end
    save(common_black_list)
    @@all_upvot50_50_posts = nil
    @@user_counter = 0
    common_black_list
  end

  def self.save(common_black_list)
    current_path = File.dirname(__FILE__)
    file_name = current_path + "/resources/blacklist.txt"
    f = File.new(file_name, "w")
    common_black_list.each do |black_list_string|
      f.puts black_list_string
    end
    f.close
  end

  def self.open
    black_list = []
    current_path = File.dirname(__FILE__)
    file_name = current_path + "/resources/blacklist.txt"
    if File.exists?(file_name)
          f= File.new(file_name, 'r:UTF-8')
          lines = f.readlines
          f.close
          lines.each do |line|
            black_list << line.strip
          end
          return black_list
    else
          return []
    end
  end

  def self.get_last_post(user_name)
    client = TinyTds::Client.new username: 'golos', password: 'golos', host: 'sql.golos.cloud', port: 1433, database: 'DBGolos'
    print "get_last_post:"
    if client.active? == true then print '->' end
    query_done = false
    while query_done != true
      begin
        tsql = "SELECT TOP 1 author, permlink, timestamp FROM TxComments WHERE parent_author = '' AND author = '#{user_name}' ORDER BY id DESC"
        result = client.execute(tsql)
        last_post = []
        result.each do |row|
          last_post << row
        end
        query_done = true
      rescue
        print "."
        sleep(1)
      end
    end
    client.close
    print 'ok '.green
    puts
    last_post #[last_post.size-1]
  end

  def self.get_comments(user_name, permlink)
    client = TinyTds::Client.new username: 'golos', password: 'golos', host: 'sql.golos.cloud', port: 1433, database: 'DBGolos'
    print "get_comments #{user_name.brown}/#{permlink.brown} "
    if client.active? == true then print '->' end
    query_done = false
    while query_done != true
      begin
        tsql = "SELECT author, permlink, body, timestamp FROM TxComments WHERE parent_author = '#{user_name}' AND parent_permlink = '#{permlink}'"
        result = client.execute(tsql)
        comments_array = []
        result.each do |row|
          comments_array << row
        end
        query_done = true
      rescue
        print "."
        sleep(1)
      end
    end
    client.close
    print 'ok '.green
    puts
    comments_result = []
    comments_array.each do |comment|
      if @@USERS_NOT_CREATE_STAT.include? comment['author']
      else
        comments_result << comment
      end
    end
    comments_result
  end

  def self.got_service_responce?(author, permlink, service_user_name)
    comments = get_comments(author, permlink)
    comments.each do |comment|
      if comment['author'] == service_user_name
      return true
      end
    end
    false
  end

  def self.service_responce(comments, service_user)
    got_responce_authors = []
    comments.each do |comment|
      if got_responce_authors.include? comment['author']
        # puts comment['author'].brown + ' alredy added to list'.cyan
      else
        if got_service_responce?(comment['author'], comment['permlink'], service_user.user_name)
          got_responce_authors << comment['author']
          # puts comment['author'].brown + ' added to list now'.green
        end # if
      end
    end
    comments.each do |comment|
      response_text = "\n#### Статистика для @#{comment['author']} актуальна на #{(Time.now.utc + 3*60*60).strftime("%Y-%m-%d %H:%M:%S")}(МСК) \n | Автор | Upvoted, шт. | Оплаченных, шт. | Оплаченных, % | \n |---|---|---|---| \n"
      puts '*********************************'.blue
      if got_responce_authors.include? comment['author']
        print comment['author'].brown
        puts ' responsed already'
      else
        result_black_list = []
        puts comment['author']
        puts "Create stat"
        statistic_hash = create_stat(comment['author'])
        statistic_array = []
        statistic_hash.map do |key, value|
          statistic_array << [key, value[0], value[1], (((value[1].to_f)/(value[0].to_f))*100).round(2)]
        end # statistic.map
        statistic_array.sort_by! {|elem| elem[3]}
        statistic_array.each do |stat_row|
          response_text = response_text + '|' + stat_row[0]+ '|' + stat_row[1].to_s+ '|' + stat_row[2].to_s+ '|' + stat_row[3].to_s + "|\n"
        end
        response_text = response_text + " Уважаемый(ая) #{comment['author']}, иногда авторам не удается указать ссылук на пост при оплате вознаграждения куратору. И сервис автору фиксирует **неоплату**. Прошу вас не заносить авторов в свой черный список только основываясь на данной статистике. Статистика создается для того, чтобы вам легче было определить каких авторов надо дополнительно перепроверить. Ещё раз повторю. **Невозможно сотавить 100% доставерную статистику автоматически, некоторые пункты требуют перепроверки живым человеком.** Прошу вас оставить обратную связь о полученных цифрах, таким образом мы можем сделать этот сервис умнее. \n Спасибо вам **#{comment['author']}** за пользование нашим сервисом."
        puts response_text
        puts "Create_response data"
        title = ''
        json_metadata = ''
        response_data = BotNet.create_comment_data(comment['permlink'], service_user.user_name, title, response_text, json_metadata, comment['author'])
        puts "send statistic to user"
        BotNet.sign_transaction(response_data, service_user.post_key, service_user)
      end # if
    end # comments.each
    @@all_upvot50_50_posts = nil
  end

  def self.new_service_post(service_user)
    if is_last_post_too_old?(service_user.user_name)
      print "is it time to create new post? "
      puts "YES".green.bold
      #создаем новый пост
      # если да то подготавливаем текст метод (хорошо бы сделать статистику по проекту 50 на 50)
      body = "Картинка 50/50 \n описание сервиса \n Автор @nerossoul"
      title = '[Сервис] Статистика для кураторов АПВОТ50-50.'
      permlink = "upvot50-50-stat" + Time.now.strftime("-%Y%m%dt%H%M%S%L") + SecureRandom.hex(1)
      json_metadata = "{\"tags\":[\"ru--apvot50-50\",\"blacklist\",\"upvot50-50-stat\"]}"
      post_data = BotNet.create_post_data('', service_user.user_name, permlink, title, body, json_metadata, '')
      puts post_data
      puts "here will be created new post"
      # подготавливаем данные для транзакции
      # транзакция...
    else
      print "is it time to create new post? "
      puts "no".cyan
    end
  end

  def self.is_last_post_too_old?(user_name)
    last_post = get_last_post(user_name)[0]
    puts last_post['timestamp']
    puts last_post['timestamp'].class
    post_time = BotNet.get_time_object_from_golos_timestamp(last_post['timestamp'].to_datetime.to_s)
    post_days_old = (Time.now.utc - post_time)/60/60/24
    if post_days_old > 1
      return true
    else
      return false
    end
  end

  def self.get_post_reward_time(author, prmlink)
    client = TinyTds::Client.new username: 'golos', password: 'golos', host: 'sql.golos.cloud', port: 1433, database: 'DBGolos'
    print "get_post_reward_time @#{author}/#{prmlink}:"
    if client.active? == true then print '->' end
    query_done = false
    while query_done != true
      begin
        tsql = "SELECT TOP 1 timestamp FROM VOAuthorRewards WHERE author = '#{author}' AND permlink = '#{prmlink}'"
        result = client.execute(tsql)
        post_reward_time = []
        result.each do |row|
          post_reward_time << row
        end
        query_done = true
      rescue
        print "."
        sleep(1)
      end
    end
    client.close
    print 'ok '.green
    puts
    if post_reward_time.size != 0
      return post_reward_time[0]['timestamp']
    else
      return false
    end
  end

  def self.get_all_upvot50_50_posts_from_file
    all_upvot50_50_posts = []
    current_path = File.dirname(__FILE__)
    file_name = current_path + "/resources/allupvot5050posts.txt"
    if File.exists?(file_name)
          f= File.new(file_name, 'r:UTF-8')
          lines = f.readlines
          f.close
          lines.each do |line|
            line_array = line.split('/')
            if line_array.size > 2
              all_upvot50_50_posts << {"author"=>line_array[0], "permlink"=>line_array[1], "timestamp"=>line_array[2].strip}
            end
          end
          return all_upvot50_50_posts#.uniq!
    else
          return []
    end
  end

  def self.save_all_upvot50_50_posts_to_file
    all_upvot50_50_posts_from_file = get_all_upvot50_50_posts_from_file
    all_upvot50_50_posts = get_all_upvot50_50_posts
    all_upvot50_50_posts_result = []
    counter = 0
    counter_goal = all_upvot50_50_posts.size
    #puts all_upvot50_50_posts_from_file
    all_upvot50_50_posts.each do |sql_post|
      counter += 1
      puts "#{counter}/#{counter_goal}"
      post_found_in_file = false
      all_upvot50_50_posts_from_file.each do |file_post|
        if sql_post['author'] == file_post['author'] && sql_post['permlink'] == file_post['permlink']
          all_upvot50_50_posts_result << file_post
          post_found_in_file = true
        end
      end
      if post_found_in_file == false
        post_reward_time = get_post_reward_time(sql_post['author'], sql_post['permlink'])
        puts "#{sql_post['author']}/#{sql_post['permlink']}/#{post_reward_time.to_s.green}"
        if post_reward_time != false
          all_upvot50_50_posts_result << {"author"=>sql_post['author'], "permlink"=>sql_post['permlink'], "timestamp"=>post_reward_time}
        end
      end
    end
    current_path = File.dirname(__FILE__)
    file_name = current_path + "/resources/allupvot5050posts.txt"
    f = File.new(file_name, "w")
    all_upvot50_50_posts_result.uniq!
    all_upvot50_50_posts_result.each do |post|
      f.puts "#{post['author']}/#{post['permlink']}/#{post['timestamp']}"
    end
    f.close
  end



end #end of class BlackList
