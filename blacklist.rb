require 'tiny_tds'
require "json"
require_relative 'stringformat.rb'

class BlackList

    @@all_upvot50_50_posts = nil
    @@user_counter = 0

  def self.get_all_user_votes(user_name)
    client = TinyTds::Client.new username: 'golos', password: 'golos', host: 'sql.golos.cloud', port: 1433, database: 'DBGolos'
    print "Get_votes:"
    if client.active? == true then print '->' end
    tsql = "SELECT author, permlink FROM TxVotes WHERE voter='#{user_name}'"
    result = client.execute(tsql)
    user_votes = []
    result.each do |row|
        user_votes << row
    end
    client.close
    print 'ok '.green
    user_votes
  end

  def self.get_all_upvot50_50_posts
  client = TinyTds::Client.new username: 'golos', password: 'golos', host: 'sql.golos.cloud', port: 1433, database: 'DBGolos'
  print 'Get_all_upvot50_50_posts:'
  if client.active? == true then print '->' end
  query_done = false
  while query_done != true
    begin
      tsql = "SELECT author, permlink FROM TxComments WHERE parent_author = '' AND json_metadata LIKE '%ru--apvot50-50%'"
      result = client.execute(tsql)
      all_upvot50_50_posts = []
      result.each do |row|
          all_upvot50_50_posts << row
      end
      query_done = true
    rescue
      print "error try again "
      sleep(1)
    end
  end
  client.close
  print 'ok '.green
  all_upvot50_50_posts
  end

  def self.get_voted_posts_upvote50_50(user_name)
    if @@all_upvot50_50_posts == nil
      @@all_upvot50_50_posts = get_all_upvot50_50_posts
    end
    all_upvot50_50_posts = @@all_upvot50_50_posts
    all_upvot50_50_posts.uniq!
    all_user_votes = get_all_user_votes(user_name)
    all_user_votes.uniq!
    result = []
    all_upvot50_50_posts.each do |post|
      all_user_votes.each do |vote|
        if post == vote
          result << post
        end
      end
    end
    result
  end

  def self.get_all_user_transfers_memo(user_name)
    client = TinyTds::Client.new username: 'golos', password: 'golos', host: 'sql.golos.cloud', port: 1433, database: 'DBGolos'
    print "Get_transfers:"
    if client.active? == true then print '->' end
    tsql = "SELECT memo FROM TxTransfers WHERE type = 'transfer' AND [to] = '#{user_name}' AND NOT [from] = 'robot' AND NOT [from] = 'golos.loto' "
    result = client.execute(tsql)
    transfers = []
    result.each do |row|
      transfers << row
    end
    client.close
    print 'ok '.green
    transfers
  end

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

  def self.get_post_paid_status(user_name)
    @@user_counter += 1
    print "#{@@user_counter}. Create stat for".green + " #{user_name.upcase} ".brown
    post_paid_status = []
    voted_posts_upvote50_50 = get_voted_posts_upvote50_50(user_name)
    paid_posts = get_paid_posts(user_name)
      voted_posts_upvote50_50.each do |voted_post|
        post_paid_status << {"author"=>voted_post["author"], "permlink"=>voted_post["permlink"], "paid" => (paid_posts.include? voted_post)}
      end
    post_paid_status
  end

  def self.create_black_list(user_name)
    black_list = {} # author voted/paid
    result_black_list = []
    post_paid_status = get_post_paid_status(user_name)
    post_paid_status.each do |post|
      if black_list[post["author"]] != nil
        black_list[post["author"]][0] += 1
        black_list[post["author"]][1] += 1 if post["paid"] == false
      else
        black_list[post["author"]] = [0,0]
        black_list[post["author"]][0] += 1
        black_list[post["author"]][1] += 1 if post["paid"] == false
      end
    end
    black_list.map do |key, value|
      if value[0] > 3
      result_black_list << "#{user_name}/#{key}" if (((value[1].to_f)/(value[0].to_f))*100) > 70
      end
    end
    puts 'DONE'.green.bold
    result_black_list
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

end #end of class BlackList
