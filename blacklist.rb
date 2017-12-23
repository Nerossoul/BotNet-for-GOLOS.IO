require 'tiny_tds'
require "json"


class BlackList


    @@all_upvot50_50_posts = nil




  def self.get_all_user_votes(user_name)
    client = TinyTds::Client.new username: 'golos', password: 'golos', host: 'sql.golos.cloud', port: 1433, database: 'DBGolos'
    print 'get_all_user_votes: Connecting to SQL Server'
    if client.active? == true then puts ' Done' end
    tsql = "SELECT author, permlink FROM TxVotes WHERE voter='#{user_name}'"
    result = client.execute(tsql)
    user_votes = []
    result.each do |row|
        user_votes << row
    end
    client.close
    user_votes
  end

  def self.get_all_upvot50_50_posts
  client = TinyTds::Client.new username: 'golos', password: 'golos', host: 'sql.golos.cloud', port: 1433, database: 'DBGolos'
  print 'get_all_upvot50_50_posts: Connecting to SQL Server'
  if client.active? == true then puts ' Done' end
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
  all_upvot50_50_posts
  end

  def self.get_voted_posts_upvote50_50(user_name)
    if @@all_upvot50_50_posts == nil
      puts "работает УРА"
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
    print 'get_all_user_transfers : Connecting to SQL Server for '
    if client.active? == true then puts ' Done' end
    tsql = "SELECT memo FROM TxTransfers WHERE type = 'transfer' AND [to] = '#{user_name}' AND NOT [from] = 'robot' AND NOT [from] = 'golos.loto' "
    result = client.execute(tsql)
    transfers = []
    result.each do |row|
      transfers << row
    end
    client.close
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
    puts "create stat for #{user_name}"
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
      if value[0] > 2
      result_black_list << "#{user_name}/#{key}" if (((value[1].to_f)/(value[0].to_f))*100) > 70
      end
    end
    result_black_list
  end

  def self.create_common_black_list(users_array)
    common_black_list = []
    users_array.each do |user|
      create_black_list(user).each do |elem|
        common_black_list << elem
      end
    end
    common_black_list
  end

  def self.save(common_black_list)
    
  end

  def self.open

  end

end #end of class BlackList

puts BlackList.create_common_black_list(['upvot50-50', 'holly'])




=begin
def get_post_info_from_sql(author, permlink)
  client = TinyTds::Client.new username: 'golos', password: 'golos', host: 'sql.golos.cloud', port: 1433, database: 'DBGolos'
  puts 'Connecting to SQL Server'
  if client.active? == true then puts 'Done' end
  tsql = "SELECT * FROM TxComments WHERE author='#{author}' and permlink='#{permlink}'"
  result = client.execute(tsql)
  post_info = []
  result.each do |row|
      post_info << row
  end
  client.close
  time_array = []
  if post_info.size > 1
    puts "много правок вытаскиваем последнюю"
    post_info.each do |post_version|
      time_array << post_version["timestamp"].to_datetime
    end
    post_info.each do |post_version|
      if time_array.max == post_version["timestamp"].to_datetime
      return [post_version]
      end
    end
    puts "done"
  end
  post_info
end

def upvote50_50?(post_info)
  if post_info[0]['parent_author'] == ''
    if JSON.parse(post_info[0]["json_metadata"])["tags"] != nil
      tags = JSON.parse(post_info[0]["json_metadata"])["tags"]
    else
      return false
    end
    tags.include? 'ru--apvot50-50'
  else
    return false
  end
end
=end
